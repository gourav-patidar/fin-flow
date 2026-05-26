# FinFlow — Claude Context File

> Personal finance manager for Indian users. Flutter + Firebase + Razorpay.
> Native biometric bridge via MethodChannel is the portfolio differentiator.

---

## 1. Project Identity

**Name:** FinFlow
**Tagline:** Smart money tracking with biometric security and bank-style UX
**Platform:** Flutter (iOS + Android), targeting Indian fintech users
**Status:** Solo build, ~2 hrs/day, 4-week timeline
**Portfolio goal:** Demonstrate senior-level cross-platform engineering — specifically the native bridge work, not just "another expense tracker"

The one-liner that goes on the portfolio:
> "Cross-platform fintech app featuring native biometric auth (iOS LocalAuthentication + Android BiometricPrompt via MethodChannel), Razorpay payment integration, real-time Firestore sync, fl_chart analytics, and PDF report export. BLoC architecture with offline-first Hive storage."

---

## 2. Architecture

**Pattern:** BLoC (flutter_bloc) with feature-first folder structure
**State:** BLoC for business logic, Hive for offline cache, Firestore for sync
**Auth:** Firebase Auth (email/password + Google) + native biometric layer
**Payments:** Razorpay sandbox (test keys only — never commit live keys)
**Storage:** Firestore (source of truth) → Hive (offline mirror) → UI

### Folder structure
```
lib/
  core/
    theme/          # Design tokens, light + dark
    routing/        # GoRouter config
    constants/      # App-wide constants, asset paths
    utils/          # Formatters (₹ Indian grouping), date helpers
    services/       # Firebase, Razorpay, biometric, PDF, CSV
  features/
    auth/
      bloc/
      data/         # Repository + Firebase data source
      presentation/ # Screens + widgets
    dashboard/
    transactions/
    payments/
    analytics/
    profile/
  shared/
    widgets/        # Reusable: GlassCard, GradientButton, etc.
    models/         # Transaction, User, Budget (with Hive adapters)
  main.dart
android/
  app/src/main/kotlin/.../BiometricBridge.kt
ios/
  Runner/BiometricBridge.swift
```

### Data flow rule
UI → BLoC → Repository → (Firestore || Hive). Repository decides; BLoC never talks to Firebase directly. This keeps screens testable and lets the offline-first story actually work.

---

## 3. The Native Bridge (Critical — Do Not Shortcut)

The biometric auth is **not** just `local_auth` package. The portfolio claim is that we built a MethodChannel bridge wrapping the native APIs. So:

- **Channel name:** `com.finflow/biometric`
- **Methods:** `isAvailable`, `authenticate`, `getEnrolledBiometrics`
- **iOS side:** `BiometricBridge.swift` using `LAContext` from `LocalAuthentication`
- **Android side:** `BiometricBridge.kt` using `BiometricPrompt` from `androidx.biometric`
- **Dart side:** `BiometricService` class wrapping the MethodChannel calls, exposing a clean Future-based API to the BLoC.

We may *also* use the `local_auth` package as a fallback or for comparison, but the showcase is the hand-rolled bridge. When working on biometric code, never delete the MethodChannel implementation in favor of just using the package — that's the whole point of the project.

---

## 4. Design System

**Font:** DM Sans (Google Fonts), weights 400/500/600/700, tabular-nums for currency
**Currency formatting:** Indian grouping always — `₹1,24,500` not `₹124,500`. Helper lives in `core/utils/currency_formatter.dart`.

### Dark mode tokens (default)
```
bg              #0A0A0F
surface         #13131A
card            #1C1C28
card-elevated   #232334
border          rgba(255,255,255,0.08)
border-strong   rgba(255,255,255,0.14)
text-primary    #FFFFFF
text-secondary  #8A8A9A
text-tertiary   #5A5A6A
accent          #7B6EF6
accent-soft     rgba(123,110,246,0.15)
income          #00D4AA
expense         #FF5C5C
warning         #FFB547
gradient-hero   135deg, #7B6EF6 → #5B4FE0
```

### Light mode tokens
```
bg              #F5F5F8
surface         #FFFFFF
card            #FFFFFF
card-elevated   #FAFAFC
border          rgba(10,10,15,0.06)
border-strong   rgba(10,10,15,0.12)
text-primary    #0A0A0F
text-secondary  #6B6B7B
text-tertiary   #A0A0B0
accent          #6358E8        ← intentionally darker than dark-mode accent for AA contrast
accent-soft     rgba(99,88,232,0.10)
income          #00B894
expense         #E53E3E
warning         #E89B2A
gradient-hero   135deg, #6358E8 → #4A3FC9
```

### Component rules
- Radii: cards 20, buttons 14, pills 999, icons 12
- Spacing scale: 4 / 8 / 12 / 16 / 20 / 24 / 32
- Cards in dark mode use glassmorphism (gradient + blur + border)
- Cards in light mode drop the blur (looks muddy on white), keep gradient + crisp shadow
- Bottom nav: 4 tabs (Home, Transactions, Analytics, Profile), active uses `accent` + `accent-soft` pill

---

## 5. Screens

1. **Onboarding** — 3 slides, Lottie animations, Skip + Next CTA
2. **Sign In** — email/password, Google, biometric (the highlight)
3. **Dashboard** — balance card (glass), income/expense pills, donut chart (fl_chart), recent transactions, quick actions
4. **Transactions** — search, filter chips, grouped by date, swipe to edit/delete, CSV/PDF export
5. **Payments** — Razorpay checkout (UPI, cards, net banking, wallets), split bill UI, success/failure animation
6. **Analytics** — line chart (monthly trend), bar chart (category breakdown), smart insight card, budget progress bars
7. **Profile** — avatar, settings groups, theme toggle, logout

All screens support both themes from day one. No "we'll add light mode later" — the tokens are in place, use them.

---

## 6. Tech Stack & Packages

```yaml
# Auth & backend
firebase_core
firebase_auth
cloud_firestore
google_sign_in

# State & routing
flutter_bloc
go_router
equatable

# Storage
hive
hive_flutter

# UI & charts
google_fonts
fl_chart
lottie
flutter_svg

# Payments
razorpay_flutter

# Native bridge (fallback / comparison)
local_auth

# Export
pdf
printing
csv
path_provider
share_plus

# Dev
build_runner
hive_generator
```

Pin versions in `pubspec.yaml` once the project stabilizes — don't let `^` ranges drift mid-build.

---

## 7. Indian Context — Use Realistic Data

When seeding data, generating screenshots, or writing tests, use Indian names, merchants, and UPI handles. This is a fintech app for India — generic "John Doe / Starbucks" data instantly breaks immersion.

- **Names:** Aarav Sharma, Priya Patel, Rohan Mehta, Ananya Iyer, Vikram Reddy
- **Merchants:** Zomato, Swiggy, BigBasket, Blinkit, Amazon, IRCTC, BSES, Airtel, HDFC, Jio
- **UPI handles:** `@okhdfcbank`, `@paytm`, `@ybl`, `@oksbi`
- **Categories:** Food & Dining, Groceries, Transport, Bills & Utilities, Shopping, Entertainment, Health, Investments

---

## 8. Build Timeline

| Week | Focus |
|------|-------|
| 1 | Auth screens + biometric MethodChannel bridge (both platforms) + dashboard UI shell |
| 2 | Transactions CRUD + Firestore wiring + Hive offline cache + fl_chart on dashboard |
| 3 | Razorpay sandbox integration + analytics screen + smart insights logic |
| 4 | PDF/CSV export + profile screen + theme toggle + polish + demo video |

If a week slips, the biometric bridge and Razorpay integration are non-negotiable — they're the portfolio anchors. Cut polish or analytics depth before cutting those.

---

## 9. Conventions

- **Naming:** features are lowercase singular (`auth`, `transaction`, `payment`), classes are PascalCase, files are snake_case
- **BLoC files:** `*_bloc.dart`, `*_event.dart`, `*_state.dart` — one BLoC per feature, not per screen
- **No business logic in widgets** — if a widget has more than a `setState` for local UI state, the logic moves to the BLoC
- **No hardcoded strings in UI** — route through a constants file or, eventually, `intl` if we localize
- **No hardcoded colors** — always pull from the theme
- **Currency** always via the `formatINR()` helper, never `toString()` on a number
- **Dates** via the `formatDate()` helper (e.g. "Today", "Yesterday", "12 May")

---

## 10. Security & Secrets

- Firebase config: `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) — gitignored, kept in `secrets/` locally
- Razorpay keys: `.env` file, loaded via `flutter_dotenv`. Sandbox keys only in this repo. Live keys go nowhere near git.
- Biometric: never store the actual biometric data. The native side returns a boolean success; the app stores a flag in Hive saying "biometric is enabled for user X."
- Firestore rules: lock reads/writes to `request.auth.uid == resource.data.userId`. Add the rules file to the repo even though it deploys separately — visibility matters.

---

## 11. How I Want Claude to Help

- **When I ask for code:** match the conventions above. Don't introduce a new state management library, don't switch to GetX, don't add unrequested packages.
- **When I ask for UI:** use the design tokens. Both themes. No improvised colors.
- **When I ask for the biometric bridge:** write the MethodChannel code on both Dart and native sides. Don't shortcut to `local_auth`.
- **When I'm stuck:** explain the trade-off, then recommend one path. Don't list five options and leave me to pick.
- **What I don't want:** AI-generated filler comments (`// This function does X`), `print` statements left in production code, or scaffolding for features I didn't ask for.

If something in this file conflicts with a specific request, the specific request wins — but flag the conflict so I can update this file.
