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
to the previous tab; the tab headers return to Home. Tap the Home expiry card
to open Points Expiry Details with the same bottom navigation. Sign Out clears the route
stack and returns to Login.

## Where to learn and edit

| Location in `lib/` | Responsibility |
| --- | --- |
| `main.dart` | Starts the app inside Riverpod's `ProviderScope` |
| `app.dart` | MaterialApp and theme |
| `core/theme/app_theme.dart` | Shared colors and input styling |
| `core/widgets/reward_widgets.dart` | Shared page header, white card, and gradient button |
| `features/home/screens/home_screen.dart` | Tab navigation and member-card route |
| `features/home/widgets/` | Home promotion/card and point header |
| `features/expiry/models/point_expiry_group.dart` | Point groups, calendar-day countdown, and next-30-days summary |
| `features/expiry/providers/expiry_provider.dart` | Mock expiry repository, async Riverpod state, and derived total |
| `features/expiry/screens/expiry_details_screen.dart` | Expiry total, dates, countdown, loading/retry, and pull-to-refresh |
| `features/expiry/widgets/home_expiry_card.dart` | Home warning that reads the same expiry state |
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

### How Riverpod expiry works

`expiryGroupsProvider` loads point groups from `PointExpiryRepository.fetchGroups()`.
`expirySummaryProvider` derives the total and sorted positive groups expiring from
**today through 30 days ahead**, inclusive. Expired groups and later dates are
excluded. Home and Points Expiry Details watch this same summary, so refreshing
the details page updates both screens. An empty result restores Home's active-points
notice. A failed refresh retains the previous groups and offers Retry.

The demo contains 120 and 200 points, each expiring 25 calendar days from the fetch
date. Dates use `DD/MM/YYYY`; countdowns compare calendar days, not elapsed hours.
Pull down the details page to refresh. Replace `fetchGroups()` with your API later.
`expiryClockProvider` can be overridden in tests to reproduce the screenshot's
30/04/2026 date and 25-day countdown without hardcoding expired April dates in the
running app. Sign Out also clears expiry state.

## Demo boundaries

Login, points, expiry, history, and password reset are local demonstrations. Password reset
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
Expiry tests cover the 30-day window, leap-year countdowns, shared Home/detail
refresh, error recovery, empty results, and system Back navigation.
GitHub Actions runs formatting, analysis, and tests on pull requests.
