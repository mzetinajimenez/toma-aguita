# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS application built with SwiftUI, targeting iOS 18.5+. The project is named "toma-aguita" and uses Xcode 16.4 for development.

- **Bundle ID**: `com.mzj.toma-aguita`
- **Development Team**: 3T7N47Z579
- **Deployment Target**: iOS 18.5
- **Swift Version**: 5.0
- **Supported Devices**: iPhone and iPad (TARGETED_DEVICE_FAMILY = "1,2")

## App Purpose

"Toma Aguita" (Spanish for "drink water") is a simple and cute water tracking app that helps users monitor their daily water intake.

### Core Features
- Track daily water consumption in cups
- Visual progress tracking toward a daily goal of 8 cups
- Cute, simple, and friendly user interface
- Lock screen widget displaying:
  - Current progress in cups (e.g., "3/8 cups")
  - Circular progress meter visualizing completion toward the 8-cup goal

### Design Philosophy
The app should maintain a lighthearted, approachable aesthetic that encourages users to stay hydrated without feeling overwhelming or clinical.

## Project Structure

```
toma-aguita/
├── toma-aguita/                        # Main app target
│   ├── toma_aguitaApp.swift           # App entry point (@main) with SwiftData setup
│   ├── ContentView.swift               # Main UI with circular progress and controls
│   ├── Models/
│   │   ├── WaterIntakeRecord.swift    # SwiftData model for daily water intake
│   │   ├── WaterIntakeManager.swift   # Business logic and data management
│   │   ├── PreferencesManager.swift   # @Observable singleton for user settings (UserDefaults via App Group)
│   │   ├── ColorSchemeOption.swift    # Enum for theme color options
│   │   └── UnitMode.swift            # Enum for measurement units (cups/oz/mL)
│   ├── Views/
│   │   ├── MainTabView.swift          # Root tab container
│   │   ├── SettingsView.swift         # User preferences UI
│   │   ├── HistoryView.swift          # Daily history list
│   │   └── SocialView.swift           # Friends/social placeholder
│   └── Assets.xcassets/               # Asset catalog
├── TomaAguitaWidget/                  # Widget extension target
│   ├── TomaAguitaWidget.swift         # Lock screen circular widget
│   └── TomaAguitaWidgetBundle.swift   # Widget bundle entry point
├── toma-aguitaTests/                  # Unit tests (Swift Testing framework)
└── toma-aguitaUITests/                # UI tests (XCTest framework)
```

## Building and Running

A `Makefile` is included for common dev tasks. Prefer `make` over raw xcodebuild.

```bash
make fmt      # Format all Swift files in place (swiftformat .)
make lint     # Check formatting without modifying files
make build    # Debug build targeting iPhone 16 simulator
make test     # Run tests on iPhone 16 simulator
make clean    # Clean build folder
```

**Important**: always pass `-destination` to xcodebuild. Without it, it defaults to "My Mac" which fails provisioning for an iOS-only profile.

### Build the app (raw)
```bash
xcodebuild -project toma-aguita.xcodeproj -scheme toma-aguita -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Build for release
```bash
xcodebuild -project toma-aguita.xcodeproj -scheme toma-aguita -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Clean build folder
```bash
xcodebuild -project toma-aguita.xcodeproj -scheme toma-aguita clean
```

## Testing

### Run unit tests
The project uses Swift Testing framework (not XCTest) for unit tests:
```bash
xcodebuild test -project toma-aguita.xcodeproj -scheme toma-aguita -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run UI tests
UI tests use XCTest framework:
```bash
xcodebuild test -project toma-aguita.xcodeproj -scheme toma-aguita -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:toma-aguitaUITests
```

### Run specific test
```bash
# Unit test
xcodebuild test -project toma-aguita.xcodeproj -scheme toma-aguita -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:toma-aguitaTests/toma_aguitaTests/example

# UI test
xcodebuild test -project toma-aguita.xcodeproj -scheme toma-aguita -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:toma-aguitaUITests/toma_aguitaUITests/testExample
```

## Architecture

### Data Layer
- **SwiftData Model**: `WaterIntakeRecord` stores daily water intake with date and cups consumed
- **Manager Pattern**: `WaterIntakeManager` is a `final @Observable` class that:
  - Manages CRUD operations for water intake records
  - Handles midnight auto-reset logic
  - Calculates progress toward daily goal
  - Stores historical data for potential future features
- **Preferences**: `PreferencesManager` is a `final @Observable` singleton that reads/writes user settings (daily goal, unit mode, color scheme) to `UserDefaults` via the App Group `group.com.mzj.toma-aguita` so the widget can share the same values

### App Entry Point
- Uses SwiftUI's `@main` attribute on `toma_aguitaApp` struct
- Initializes SwiftData `ModelContainer` for `WaterIntakeRecord`
- Injects model context into SwiftUI environment
- Creates `WindowGroup` containing root `ContentView`

### Main UI (`ContentView`)
- Uses `@Environment(\.modelContext)` to access SwiftData
- Monitors `scenePhase` to trigger midnight reset checks when app becomes active
- Features:
  - Circular progress indicator with animations
  - Button cluster for adding water (+0.5, +1, +2 cups)
  - Remove and reset functionality
  - Haptic feedback on all interactions
  - Celebration effects when reaching daily goal

### Widget Architecture
- **WidgetKit Extension**: Lock screen circular widget (`accessoryCircular`)
- **Timeline Provider**: Updates hourly, fetches current day's water intake from SwiftData
- **Shared Data**: Widget reads from the same SwiftData container as the main app
- **Visual Design**: Matches main app aesthetic with circular progress ring

### Testing Structure
- **Unit Tests**: Located in `toma-aguitaTests/`, using the Swift Testing framework with `@Test` attribute
- **UI Tests**: Located in `toma-aguitaUITests/`, using XCTest with `XCUIApplication` for UI automation

### Key Features Implementation
- **Midnight Reset**: Checked on app activation via `scenePhase` change to `.active`
- **Data Persistence**: Automatic via SwiftData, no manual save needed
- **Progress Calculation**: `min(cupsConsumed / 8.0, 1.0)` in `WaterIntakeManager`
- **Goal Celebration**: Triggered when progress crosses 1.0 threshold with haptic success notification

## Widget Setup

The widget source files are included in `TomaAguitaWidget/`, but the Widget Extension target must be added manually in Xcode. See `WIDGET_SETUP.md` for complete step-by-step instructions.

Quick steps:
1. Add new Widget Extension target in Xcode (name: `TomaAguitaWidget`)
2. Add the widget Swift files to the new target
3. Share the model files with both targets
4. Build and run

## Tooling

### SwiftFormat
`.swiftformat` is checked in at the repo root. Run `make fmt` before committing.

Active opt-in rules: `isEmpty`, `privateStateVariables`, `unusedPrivateDeclarations`, `blockComments`, `wrapConditionalBodies`, `wrapEnumCases`, `organizeDeclarations`, `preferFinalClasses`.

`conditionalAssignment` is disabled to avoid `let x = if … { } else { }` one-liners.

`organizeDeclarations` adds `// MARK: Lifecycle / Internal / Private` sections — this is the expected member ordering across all types in the codebase.

## Development Notes

- SwiftUI Previews are enabled (`ENABLE_PREVIEWS = YES`)
- The project uses automatic code signing
- Asset symbol generation is enabled for type-safe asset access
- User script sandboxing is enabled
- The project builds targets in parallel (`BuildIndependentTargetsInParallel = 1`)
- SwiftData is used for persistence (iOS 17+)
- Haptic feedback requires a physical device to test (simulators don't support haptics)
