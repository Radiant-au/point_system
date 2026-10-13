# Galaxy Reward

A beginner-friendly Flutter rewards demo based on the Point System Figma designs.

## Run

Use a Flutter SDK with Dart 3.13.5 or newer, as required by the existing project.

```bash
flutter pub get
flutter run
```

Splash opens Login. A valid phone number (7–15 digits) and any non-empty password
enter the demo. Bottom navigation opens Home, Rewards, History, and Profile.
The center QR button and the Home membership card open Member Card. Back returns
to the previous tab; the tab headers return to Home. Sign Out clears the route
stack and returns to Login.

## Where to learn and edit

| Location in `lib/` | Responsibility |
| --- | --- |
| `main.dart` | Starts the app inside Riverpod's `ProviderScope` |
| `app.dart` | MaterialApp and theme |
| `core/theme/app_theme.dart` | Shared colors and input styling |
| `core/widgets/reward_widgets.dart` | Shared page header, white card, and gradient button |
| `features/home/screens/home_screen.dart` | Tab navigation and member-card route |
| `features/home/widgets/` | Existing Home promotion/card and active-points header |
| `features/points/providers/points_provider.dart` | Mock points repository and async Riverpod state |
| `features/points/widgets/point_balance.dart` | Shared balance, loading/error state, and refresh action |
| `features/member/providers/member_provider.dart` | Demo member details shared by Home, Profile, and QR |
| `features/member/screens/member_card_screen.dart` | Checkout QR and member details |
| `features/rewards/screens/rewards_screen.dart` | Earning and redemption rules |
| `features/history/providers/history_provider.dart` | Editable demo transaction list |
| `features/history/screens/history_screen.dart` | Earned/redeemed transaction cards |
| `features/profile/screens/profile_screen.dart` | Member summary, reset navigation, and sign out |
| `features/auth/screens/reset_password_screen.dart` | Password validation and success dialog |

### How Riverpod points work

`PointsRepository.fetchBalance()` supplies the demo balance of **1450**. Replace
that method with an API request later. `pointsProvider` stores its async result.
Both balance widgets use `ref.watch(pointsProvider)`, so a refreshed balance
updates Home and Member Card together. The refresh button calls
`ref.read(pointsProvider.notifier).refresh()`; refresh keeps the previous balance
visible, disables duplicate requests, and allows retry after an error.

Change the mock balance in `PointsRepository`, member details in `memberProvider`,
and transaction rows in `historyProvider`. The history uses valid dates, including
`25/03/2026` in place of the screenshot's `25/30/2026`.

## Demo boundaries

Login, points, history, and password reset are local demonstrations. Password reset
checks eight characters, an uppercase letter, a number, and matching confirmation,
then shows the supplied success dialog; it does not change or store credentials.
No backend, persistent session, or checkout redemption API is connected. The QR
encodes the mock member ID; production checkout must define its own validated
payload and authorization. Rewards shows rules, as in the supplied image.

## Checks

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Tests cover shared point refresh and error retry, tab navigation, member QR data,
password validation and success, sign out, and compact layouts with a keyboard.
GitHub Actions runs formatting, analysis, and tests on pull requests.
