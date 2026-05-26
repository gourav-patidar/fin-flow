# FinFlow

> Cross-platform personal finance manager for Indian users.
> Portfolio showcase of senior-level Flutter engineering — native biometric bridge, BLoC architecture, fl_chart analytics, and offline-first Hive storage.

---

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.41.6 · Dart 3.11.4 |
| Architecture | BLoC (flutter_bloc 9.1) + feature-first folders |
| Navigation | GoRouter 14 with auth-state redirects |
| Local storage | Hive 2 (offline-first, TypeAdapter codegen) |
| Theme persistence | SharedPreferences |
| Charts | fl_chart 0.69 (line chart + pie chart) |
| Native bridge | MethodChannel — `com.finflow/biometric` |
| Export | pdf 3 + share_plus (PDF statement + CSV) |
| DI | get_it (locator pattern) |
| Fonts | DM Sans via google_fonts (tabular-nums for currency) |

---

## Portfolio differentiator — native biometric bridge

The biometric auth is **not** the `local_auth` package. It's a hand-rolled
`MethodChannel` bridge wrapping each platform's native API:

- **iOS** — `BiometricBridge.swift` using `LAContext` from `LocalAuthentication`
- **Android** — `BiometricBridge.kt` using `BiometricPrompt` from `androidx.biometric`
- **Dart** — `BiometricService` wrapping the channel, exposing a clean Future-based API

Channel name: `com.finflow/biometric`  
Methods: `isAvailable` · `authenticate` · `getEnrolledBiometrics`

---

## Screens & flows

### Onboarding
Three-slide carousel (Lottie animations) shown once on first launch.
Preference stored in SharedPreferences; never shown again after completion.

### Sign In
- Email + password (any valid-format email, password ≥ 6 chars)
- Google Sign-In → signs in as mock user `Aarav Sharma`
- Biometric quick-unlock (requires enabling it from Profile first)
- Error state: use `fail@test.com` to force a credential-failure UI

> Signed-in state persists across cold restarts via Hive cache —
> mirrors real Firebase Auth behaviour without the network dependency.

### Dashboard
- Gradient glass balance card (total income − expenses)
- Income / expense summary pills
- Donut chart (fl_chart PieChart) — spend breakdown by category
- Recent transactions list with skeleton loader during initial hydration
- Quick-action strip → shortcut to add a transaction
- FAB opens the Add Transaction bottom sheet

### Transactions
- Month-scoped list grouped by day ("Today", "Yesterday", "12 May")
- Search bar (filters by merchant / note)
- Filter chips: All · Income · Expense · each category
- Swipe-to-delete with haptic feedback
- CSV export via share_plus
- Empty state with prompt to add the first transaction
- Skeleton loader while Hive stream hydrates

### Analytics
- Animated period tabs: Week · Month · 3M · Year · All
- Line chart (fl_chart) — cumulative spend curve, gradient fill,
  dashed budget reference line (week / month only), "today" dot marker
- Income vs. expense summary + period-over-period delta %
- Category progress bars with trend arrows (↑ / ↓ vs previous period)
- Rule-based insight card: biggest saving → total % down → top category
- Skeleton loader during data computation

### Profile
- Gradient avatar hero with user initials
- Stats strip: XP points (transactions × 10) · day streak · total transactions
- Theme segmented button: Light / Auto / Dark (persisted, live-updates the whole app instantly)
- Biometric unlock toggle (binds / unbinds current user's UID)
- Export PDF statement (A4 — income/expense summary + full transaction table)
- Export CSV (all transactions, newest first)
- Sign out with confirmation dialog

---

## Running locally

```bash
flutter pub get
flutter run
```

No Firebase project, no `google-services.json`, no network calls required.
Everything runs on local Hive storage and mock services out of the box.

---

## Sign-in credentials

| Method | How it works |
|---|---|
| Email + password | Any valid-format email + password ≥ 6 chars |
| `fail@test.com` | Forces the error UI (wrong credentials state) |
| Google button | Signs in as mock user `Aarav Sharma` |
| Biometric | Enable it from Profile first, then use at sign-in |

---

## Design system

Font: **DM Sans** — weights 400 / 500 / 600 / 700, tabular figures for currency alignment.

Currency always formatted with Indian grouping: `₹1,24,500` (not `₹124,500`).

| Token | Dark | Light |
|---|---|---|
| Background | `#0A0A0F` | `#F5F5F8` |
| Surface | `#13131A` | `#FFFFFF` |
| Card | `#1C1C28` | `#FFFFFF` |
| Accent | `#7B6EF6` | `#6358E8` |
| Income | `#00D4AA` | `#00B894` |
| Expense | `#FF5C5C` | `#E53E3E` |
| Warning | `#FFB547` | `#E89B2A` |

Cards in dark mode: glassmorphism (gradient + blur + border).  
Cards in light mode: gradient + crisp shadow (no blur).

---

## Project structure

```
lib/
  core/
    constants/      # Spacing scale
    di/             # get_it locator
    routing/        # GoRouter, route names
    services/       # BiometricService, SeedService, ThemePreferences
    theme/          # AppTheme, AppColors (dark + light tokens)
    utils/          # formatINR(), formatDate()
  features/
    auth/           # BLoC + MockAuthRepository + AuthLocalStore
    dashboard/      # BLoC + BalanceCard, DonutChart, AddTransactionSheet
    transactions/   # BLoC + LocalTransactionRepository (Hive)
    analytics/      # BLoC — period ranges, chart data, category stats, insights
    profile/        # BLoC — XP/streak, theme toggle, PDF/CSV export
    onboarding/     # 3-slide carousel + OnboardingPreferences
  shared/
    models/         # Transaction, AppUser, Budget (Hive TypeAdapters)
    widgets/        # GlassCard, GradientButton, BottomNav, Skeleton, CategoryIcon
  main.dart
android/
  app/src/main/kotlin/.../BiometricBridge.kt
ios/
  Runner/BiometricBridge.swift
```

### Data flow

```
UI → BLoC → Repository → Hive box
              ↑
        Abstract interface
     (swap to Firestore later
      with one locator change)
```

---

## App icon

Configuration is ready for `flutter_launcher_icons`. To apply:

1. Place a 1024 × 1024 PNG at `assets/icon/app_icon.png`
2. Place the adaptive foreground layer at `assets/icon/app_icon_fg.png`
3. Run:

```bash
dart run flutter_launcher_icons
```

---

## Routes

| Path | Screen |
|---|---|
| `/onboarding` | First-run carousel |
| `/signin` | Auth screen |
| `/home` | Dashboard |
| `/transactions` | Transactions list |
| `/analytics` | Charts & insights |
| `/profile` | User profile & settings |
| `/kit` | Design-system gallery (dev only) |

---

## Analysis

```bash
flutter analyze
```
