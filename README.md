# Galaxy Reward

A small Flutter loyalty app with Riverpod state, a local SQLite database, and a
Dio client for an optional rewards API. The existing Figma screen designs are kept.

## Run locally

Use Flutter with Dart 3.13.5 or newer.

```bash
flutter pub get
flutter run
```

With no API URL, the app creates `galaxy_rewards.db` and seeds one demo member,
a 1450-point balance, six transactions, and two expiry groups (120 + 200 points).
The database is created once. Restarting, refreshing, or signing out does not
reseed it or move the expiry dates. Those dates start 25 calendar days after the
first database creation.

Splash opens Login. A valid phone number and a non-empty password enter the demo.
The tabs, member QR, expiry details, and password-reset dialog work as before.
Login and password reset remain UI demonstrations; no credentials are stored.

SQLite runs on Android, iOS, macOS, Linux, and Windows. Mobile/macOS use `sqflite`;
Linux/Windows use `sqflite_common_ffi`. Browser SQLite is not configured.

## Home promotions

Home uses Flutter's `PageView` for three swipeable demo offers, with smooth
indicator navigation and animated dots. Network photos come from Unsplash; the
bundled photo stays visible while loading or when offline. Edit `homePromotions`
in `lib/features/home/widgets/promotion_carousel.dart` to change the offers and
image URLs. Large text expands the banner, and reduced motion disables indicator
animations. The page index belongs to the widget; shared rewards data stays in
Riverpod.

## Connect a Dio API

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example/api/
```

The client makes **GET `members/1900190000956102/rewards`**, relative to that base
URL. See [the response contract](docs/api-contract.md) for a complete JSON example.
Use `--dart-define=API_MEMBER_ID=...` to select a different member's cache/API path.
A member with no saved rows needs a successful API response before it can be shown.

For an Android emulator and a local server on your computer:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/
```

Android debug builds allow local HTTP. Release builds and Apple mobile apps should
use HTTPS. Android includes INTERNET permission; macOS enables outgoing network
connections. Requests have eight-second timeouts. This is a client integration;
connect your backend's URL and add its authentication through `dioProvider` when
that API is ready.

When a configured API succeeds, its full snapshot replaces that member's SQLite
cache in one transaction. Connection/timeouts and temporary server outages can
use saved rows, with a notice on Home. Authentication errors, wrong-member
responses, and malformed data are surfaced and do not overwrite saved rows.

## Simple database design

The executable version-1 schema is [assets/database/schema.sql](assets/database/schema.sql).

| Table | Main columns | Purpose |
| --- | --- | --- |
| `members` | `id` (PK), `name`, `phone`, `membership_type`, `points_balance` | Member details and the server's cached balance |
| `point_transactions` | `id` (PK), `member_id` (FK), `branch`, signed `points`, `occurred_at` | Earned/redeemed history |
| `expiry_groups` | `id` (PK), `member_id` (FK), positive `points`, `expiry_date` | Remaining points grouped by expiry date |

Each child row belongs to one member. Foreign keys use `ON DELETE CASCADE`.
Indexes support history sorting and expiry lookup by member/date. Transactions
use UTC ISO timestamps; expiry dates use `YYYY-MM-DD` calendar dates. IDs are
globally unique within each table. Constraints reject negative balances, zero
transaction amounts, non-integer points, and non-positive expiry amounts.

The balance is a server-provided value, not the sum of the displayed history:
that history may contain only recent transactions. SQLite is a local cache;
checkout earning/redemption rules and authoritative balance changes belong in
the backend. The schema has no password or token columns.

## How the code fits together

| File/folder under `lib/` | Responsibility |
| --- | --- |
| `main.dart`, `app.dart` | ProviderScope, app entry, and theme |
| `core/database/app_database.dart` | Opens/version-checks SQLite, seeds once, reads and atomically saves snapshots |
| `core/database/database_location*.dart` | Chooses mobile or desktop storage and the database path |
| `core/network/rewards_api.dart` | Dio configuration, GET call, and response/member validation |
| `core/data/rewards_snapshot.dart` | Typed payload and JSON validation |
| `core/data/demo_rewards.dart` | First-creation demo seed data |
| `core/data/rewards_repository.dart` | API → SQLite sync and offline fallback |
| `core/data/rewards_provider.dart` | Database/Dio dependencies and the shared async Riverpod state |
| `core/widgets/rewards_load_state.dart` | Initial loading/error/retry UI |
| `features/member/models/`, `features/history/models/`, `features/expiry/models/` | Plain Dart data models |
| `features/*/providers/` | Small selectors reading member, balance, history, and expiry from the shared state |
| `features/*/screens/`, `features/*/widgets/` | The existing UI and navigation |

Read `rewards_provider.dart` first: `rewardsProvider` loads one `RewardsSnapshot`.
Each feature uses `ref.watch` to select its part of that snapshot. Refreshing points,
History, or expiry calls `ref.read(rewardsProvider.notifier).refresh()`, so all
screens update together. Repeated refresh requests are ignored while loading.
A failed refresh keeps the previous snapshot visible and offers retry.

Expiry totals are derived from positive groups expiring today through day 30,
inclusive. Countdown calculations use calendar days and handle month/leap-year
boundaries. Empty results restore Home's active-points notice. Sign Out clears
Riverpod's loaded state while leaving the persisted cache available for the next
demo login.

Change the initial sample data in `createDemoRewards()`. Existing installations
keep their saved rows; changing a seed does not change an existing database.
For schema changes, increment the version and add an `onUpgrade` migration.

## Checks

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Tests use real SQLite files/FFI for persistence, constraints, transaction rollback,
and cache updates. Dio adapter tests check requests, fallback, authentication
errors, and invalid responses. A SQLite-backed widget test verifies data reaches
Home, History, Profile, and expiry. Provider tests cover shared refresh and error
retention; existing navigation, QR, password-form, and compact-screen checks remain.

## .NET backend integration

Run migrations and the manual `--seed-demo` command in `dotnet_point_system` first.
The demo phone is `09123456789`; use the password supplied to the seed command.

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5297/api/
```

Use `http://127.0.0.1:5297/api/` on Linux desktop, or your server's LAN IP on a
physical phone. The server must listen on an interface reachable by the device.
Android debug builds permit local HTTP; use HTTPS for production.

Login uses `/api/auth/login`; the returned member ID selects the rewards endpoint
and SQLite cache. Password changes use `/api/auth/change-password` and require a
new login. Logout revokes the bearer token when the server is reachable and always
clears the local session. Tokens stay in memory, so each app restart requires login.
Remember me requests the backend's 30-day token lifetime; it does not persist login
across restarts. Passwords and tokens are never saved in SQLite.

Rewards are fetched from the API and atomically saved to SQLite. Network failures
and server errors can fall back to that member's saved snapshot. Authentication
errors never fall back to cached data. Refresh retries the API. Fresh installations
no longer seed local demo data; the backend owns accounts and point balances.
Offline login and offline point mutations are not supported. POS earning and
redemption remain server-authorized admin operations.

Validation commands: `flutter analyze` and `flutter test`.
