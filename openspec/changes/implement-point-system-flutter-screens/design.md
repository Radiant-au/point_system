## Context

The workspace initially contained OpenSpec configuration but no Flutter application source or package manifest. The supplied Point System Figma file contains the Splash, Login, and Home frames; the requested app has no backend requirement.

## Goals / Non-Goals

**Goals:**
- Create a beginner-readable Flutter app in this workspace with the requested `lib/` feature folders.
- Implement the Splash, mock Login, and Home flow with responsive layouts and the supplied Figma styling.
- Keep state local and use Flutter SDK APIs, with `flutter_svg` for the supplied logo assets.

**Non-Goals:**
- Real authentication, API calls, persistence, or additional complete destinations.
- A general design system or architecture beyond what these screens need.

## Decisions

- Use `MaterialApp` and named route constants or direct `Navigator` routes for the three-screen flow; choose the simpler form that fits the source layout during implementation. Splash and successful Login replace the current route so Back does not return to a completed step.
- Use `StatefulWidget` for password visibility, remember-me, form validation, and placeholder bottom-navigation selection. Keep mock point, expiry, promotion, and membership values together in the Home screen or its widgets so a beginner can edit them.
- Use a shared `ThemeData` for Figma-derived colors and text styles, with screen-level layout code and only readable, reused card/widget extractions. Use `flutter_svg` to render the supplied logo assets.
- Use scrolling and safe insets on Login so the focused fields and submit action remain reachable above the keyboard; constrain Home content to the available width and allow vertical scrolling on short phones.
- Treat the supplied Figma frames as the source for visual values and use the provided logo and promotion assets.

## Risks / Trade-offs

- Browser captures can differ from native status bar and system font rendering → compare at the supplied 360-pixel frame width and retain safe-area handling.
- Mock credentials have no server-side security or persistence → clearly keep Login as a demonstration flow and do not store the password.

## Migration Plan

No migration is needed. Create the Flutter project files in this workspace, then implement the feature folders and run `flutter analyze`.

## Open Questions

None. Sample content and phone/password validation use the requested mock flow.
