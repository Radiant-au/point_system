# Galaxy Reward

A small Flutter loyalty app with Riverpod state, a local SQLite cache, and a Dio
client for the rewards API. The existing Figma screen designs are kept.

## Run locally

Use Flutter with Dart 3.13.5 or newer. The app connects to
`http://192.168.89.226:5297/api/` by default; override it with `API_BASE_URL`
when running against another server.

```bash
flutter pub get
flutter run
```

Login and password reset use the backend. Member details, point balance, history,
and expiry groups come from the backend rewards response. SQLite stores a local
snapshot for display during temporary network or server outages.

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

The app signs in with `POST auth/login`, then fetches
`GET members/{memberId}/rewards` using the ID returned by the backend. See
[the response contract](docs/api-contract.md) for the rewards JSON shape.

For an Android emulator and a local server on your computer, override the default:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/
```

For a physical phone, use the host computer's LAN IP and ensure both devices are
on the same network and the API listens on a reachable interface. Android debug
builds allow local HTTP. Release builds and Apple mobile apps should use HTTPS.
Requests have eight-second timeouts.

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

Password changes use `/api/auth/change-password`; logout clears the local session.
Bearer tokens stay in memory and are never written to SQLite. Rewards responses
are validated before they replace the cached snapshot. Network/server failures can
show saved data; authentication errors and malformed responses are surfaced.
