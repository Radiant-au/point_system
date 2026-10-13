## Why

This workspace has no Flutter app yet, so the requested point system experience has no screens or navigation to build on. A small Flutter app covering only Splash, Login, and Home will provide the requested mock flow and a clear starting point for future work.

## What Changes

- Add a Flutter app structure with a shared theme and focused Splash, auth, and Home features.
- Add a timed Splash-to-Login transition and a mock Login form with phone/password fields, password visibility, remember-me state, basic validation, and navigation to Home on valid input.
- Add a responsive Home screen with mock point balance, expiry warning, promotion and membership cards, and bottom navigation; non-home destinations remain placeholders.
- Match colors, typography, spacing, cards, and navigation styling to the supplied Figma design during implementation.
- Keep state in Flutter built-ins and add only `flutter_svg` to render the supplied logo assets.

## Capabilities

### New Capabilities
- `point-system-screens`: Splash, mock authentication, Home content, navigation, and responsive presentation for the requested three-screen app.

### Modified Capabilities

None.

## Impact

- Creates `pubspec.yaml` and the Flutter source under `lib/` in this workspace.
- Uses Flutter SDK widgets and navigation, plus `flutter_svg` for the supplied logos; login and Home data are local mock values with no backend or persistence.
- The supplied Point System Figma file defines the Splash, Login, and Home styling. Its logo and promotion image assets are included locally.
