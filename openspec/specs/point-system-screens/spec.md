## Purpose
Define the point system app's initial Splash, Login, and Home screen behavior and presentation.

## Requirements

### Requirement: Splash transitions to Login
The app SHALL show a Splash screen on launch and automatically navigate to Login after a short delay.

#### Scenario: Splash completes
- **WHEN** the short Splash delay elapses
- **THEN** Login is shown and Back does not return to Splash

### Requirement: Login validates mock credentials
The Login screen SHALL provide phone number and password fields, a password visibility toggle, a remember-me control, and basic validation. Valid input SHALL enter Home without making a network request.

#### Scenario: Empty or invalid input
- **WHEN** the user submits a missing or invalid phone number or an empty password
- **THEN** the screen displays validation feedback and remains on Login

#### Scenario: Valid mock login
- **WHEN** the user submits a valid phone number and non-empty password
- **THEN** Home is shown without a network request and Back does not return to Login

#### Scenario: Password visibility and remember-me
- **WHEN** the user toggles password visibility or remember-me
- **THEN** the password display or checkbox state updates immediately

### Requirement: Home presents mock point membership content
Home SHALL show a mock point balance, an expiry warning, a promotion card, a membership card, and bottom navigation. Navigation items other than Home MAY be placeholders.

#### Scenario: Home is displayed
- **WHEN** Login succeeds
- **THEN** all four requested content areas and bottom navigation are visible on Home

#### Scenario: Placeholder destination selected
- **WHEN** the user selects a bottom-navigation item other than Home
- **THEN** its selected state updates and the app does not imply that an unimplemented destination is complete

### Requirement: Screens adapt to phone size and keyboard
The three screens SHALL respect safe areas and adapt to available phone dimensions. Login SHALL keep its form usable when the keyboard is open without overflow.

#### Scenario: Login keyboard is open
- **WHEN** the phone keyboard covers part of the Login viewport
- **THEN** the user can scroll to and activate the Login action without a layout overflow

#### Scenario: Compact phone layout
- **WHEN** Home is shown on a short or narrow phone
- **THEN** content remains readable and reachable through scrolling without horizontal overflow

### Requirement: Visual styling follows Figma
The screen colors, typography, spacing, cards, and bottom navigation SHALL follow the supplied Figma reference.

#### Scenario: Screens are compared with reference
- **WHEN** the Splash, Login, and Home screens are rendered for review
- **THEN** their visual styling uses the matching Figma values and layout treatments
