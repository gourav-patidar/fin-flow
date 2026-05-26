package com.finflow

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Host activity. Uses [FlutterFragmentActivity] (not the default
 * [FlutterActivity]) because BiometricPrompt requires a FragmentActivity.
 *
 * Registers the [BiometricBridge] MethodChannel so the Dart side of FinFlow
 * can talk to native biometric APIs.
 */
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(BiometricBridge())
    }
}
