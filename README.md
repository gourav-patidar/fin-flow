# FinFlow

> Personal finance manager for Indian users. Flutter + (mocked) Firebase + (mocked) Razorpay.
> The portfolio differentiator is the native biometric MethodChannel bridge.

See [CLAUDE.md](CLAUDE.md) for the full architecture overview and design tokens,
and [prompt_phases/FINFLOW_BUILD_PHASES.md](prompt_phases/FINFLOW_BUILD_PHASES.md)
for the 12-phase build plan.

---

## Mock-mode build

Every backend integration (Firebase Auth, Firestore, Google Sign-In, Razorpay)
is **stubbed behind a clean interface** in this build. There are no real
network calls and no real credentials. Look for `// TODO(integration):`
markers — that's where the real implementation plugs in (Phase 12).

| Service | Mock | Real swap target (Phase 12) |
|---|---|---|
| Auth | `MockAuthRepository` | `FirebaseAuthRepository` |
| Transactions store | `LocalTransactionRepository` (Hive) | `FirestoreTransactionRepository` |
| Payments | `MockPaymentService` | `RazorpayPaymentService` |

---

## Running

```bash
flutter pub get
flutter run
```

---

## Sign-in test credentials (mock mode)

The app accepts any well-formed email + password ≥ 6 characters:

- Email: anything that passes the format check (e.g. `aarav@finflow.app`)
- Password: any string with 6+ characters

Special cases:

- **`fail@test.com`** → forces the failure UI ("Wrong email or password"),
  useful for previewing error states.
- **Google button** → signs you in as `Aarav Sharma` (hardcoded mock user).
- **Biometric button** → currently shows "Coming in next build"; Phase 4
  wires it to the native MethodChannel bridge.

Signed-in user is persisted to `SharedPreferences` so the auth state
survives a cold restart, matching real Firebase behaviour.

---

## Developer routes

- `/onboarding` — first-run carousel
- `/signin` — auth screen
- `/home` — placeholder dashboard (Phase 6 replaces it)
- `/kit` — design-system gallery (Phase 1; remove before shipping)

---

## Testing

```bash
flutter analyze
flutter test
```
