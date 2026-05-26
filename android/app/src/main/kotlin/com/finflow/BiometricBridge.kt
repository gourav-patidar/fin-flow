package com.finflow

import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/**
 * Hand-rolled MethodChannel bridge to Android BiometricPrompt.
 *
 * Channel: com.finflow/biometric
 * Methods:
 *   - isAvailable() -> Bool
 *   - getEnrolledBiometrics() -> List<String>  // "face" | "fingerprint" | "iris"
 *   - authenticate(reason: String) -> Map { status, message }
 */
class BiometricBridge : FlutterPlugin, ActivityAware, MethodCallHandler {

    companion object {
        const val CHANNEL = "com.finflow/biometric"
    }

    private var channel: MethodChannel? = null
    private var activity: FragmentActivity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachActivity(binding.activity as? FragmentActivity)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachActivity(binding.activity as? FragmentActivity)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    private fun attachActivity(act: FragmentActivity?) {
        activity = act
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> result.success(isBiometricAvailable())
            "getEnrolledBiometrics" -> result.success(getEnrolledBiometrics())
            "authenticate" -> {
                val reason = call.argument<String>("reason") ?: "Authenticate"
                authenticate(reason, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun isBiometricAvailable(): Boolean {
        val ctx = activity ?: return false
        val manager = BiometricManager.from(ctx)
        return manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG or
            BiometricManager.Authenticators.BIOMETRIC_WEAK) == BiometricManager.BIOMETRIC_SUCCESS
    }

    private fun getEnrolledBiometrics(): List<String> {
        val ctx = activity ?: return emptyList()
        val manager = BiometricManager.from(ctx)
        val canAuth = manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG or
            BiometricManager.Authenticators.BIOMETRIC_WEAK)
        if (canAuth != BiometricManager.BIOMETRIC_SUCCESS) return emptyList()
        // Android's BiometricManager does not expose granular sensor types in a
        // stable API, so we report a generic "fingerprint" entry — the OS sheet
        // shows the correct prompt automatically.
        return listOf("fingerprint")
    }

    private fun authenticate(reason: String, result: MethodChannel.Result) {
        val act = activity
        if (act == null) {
            result.success(mapOf("status" to "failed", "message" to "No activity"))
            return
        }

        val manager = BiometricManager.from(act)
        val canAuth = manager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG or
            BiometricManager.Authenticators.BIOMETRIC_WEAK)
        if (canAuth == BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED) {
            result.success(mapOf("status" to "notEnrolled"))
            return
        }
        if (canAuth != BiometricManager.BIOMETRIC_SUCCESS) {
            result.success(mapOf("status" to "failed",
                "message" to "Biometrics unavailable (code $canAuth)"))
            return
        }

        val executor = ContextCompat.getMainExecutor(act)
        val prompt = BiometricPrompt(act, executor, object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(r: BiometricPrompt.AuthenticationResult) {
                result.success(mapOf("status" to "success"))
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                val status = when (errorCode) {
                    BiometricPrompt.ERROR_USER_CANCELED,
                    BiometricPrompt.ERROR_CANCELED,
                    BiometricPrompt.ERROR_NEGATIVE_BUTTON -> "userCancelled"
                    BiometricPrompt.ERROR_LOCKOUT,
                    BiometricPrompt.ERROR_LOCKOUT_PERMANENT -> "lockedOut"
                    BiometricPrompt.ERROR_NO_BIOMETRICS -> "notEnrolled"
                    else -> "failed"
                }
                val payload = mutableMapOf<String, Any?>("status" to status)
                if (status == "failed") payload["message"] = errString.toString()
                result.success(payload)
            }

            override fun onAuthenticationFailed() {
                // Single attempt failed but user may retry. We don't end the
                // promise here — the OS sheet allows retries until lockout or
                // user cancel.
            }
        })

        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Unlock FinFlow")
            .setSubtitle(reason)
            .setNegativeButtonText("Cancel")
            .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.BIOMETRIC_WEAK)
            .build()

        prompt.authenticate(info)
    }
}
