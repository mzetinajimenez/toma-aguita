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
│   │   └── WaterIntakeManager.swift   # Business logic and data management
│   └── Assets.xcassets/               # Asset catalog
├── TomaAguitaWidget/                  # Widget extension (needs to be added as target)
│   ├── TomaAguitaWidget.swift         # Lock screen circular widget
│   └── TomaAguitaWidgetBundle.swift   # Widget bundle entry point
├── toma-aguitaTests/                  # Unit tests (Swift Testing framework)
└── toma-aguitaUITests/                # UI tests (XCTest framework)
```

## Building and Running

### Build the app
```bash
xcodebuild -project toma-aguita.xcodeproj -scheme toma-aguita -configuration Debug build
```

### Build for release
```bash
xcodebuild -project toma-aguita.xcodeproj -scheme toma-aguita -configuration Release build
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
- **Manager Pattern**: `WaterIntakeManager` is an `@Observable` class that:
  - Manages CRUD operations for water intake records
  - Handles midnight auto-reset logic
  - Calculates progress toward 8-cup daily goal
  - Stores historical data for potential future features

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

## Development Notes

- SwiftUI Previews are enabled (`ENABLE_PREVIEWS = YES`)
- The project uses automatic code signing
- Asset symbol generation is enabled for type-safe asset access
- User script sandboxing is enabled
- The project builds targets in parallel (`BuildIndependentTargetsInParallel = 1`)
- SwiftData is used for persistence (iOS 17+)
- Haptic feedback requires a physical device to test (simulators don't support haptics)
