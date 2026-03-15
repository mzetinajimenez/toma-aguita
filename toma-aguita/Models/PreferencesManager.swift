//
//  PreferencesManager.swift
//  toma-aguita
//

import Foundation
import SwiftUI
import WidgetKit

@Observable
final class PreferencesManager {
    // MARK: Lifecycle

    private init() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.mzj.toma-aguita") else {
            fatalError("Failed to initialize UserDefaults with App Group")
        }
        userDefaults = sharedDefaults

        let storedGoal = sharedDefaults.double(forKey: Keys.dailyGoal)
        dailyGoal = storedGoal != 0 ? storedGoal : 8.0

        if let rawUnit = sharedDefaults.string(forKey: Keys.defaultUnitMode),
           let mode = UnitMode(rawValue: rawUnit)
        {
            defaultUnitMode = mode
        } else {
            defaultUnitMode = .cups
        }

        if let rawScheme = sharedDefaults.string(forKey: Keys.colorScheme),
           let scheme = ColorSchemeOption(rawValue: rawScheme)
        {
            colorScheme = scheme
        } else {
            colorScheme = .cyan
        }
    }

    // MARK: Internal

    static let shared = PreferencesManager()

    /// Stored properties so @Observable can track changes
    var dailyGoal: Double {
        didSet {
            userDefaults.set(dailyGoal, forKey: Keys.dailyGoal)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    var defaultUnitMode: UnitMode {
        didSet {
            let step = stepSize(for: defaultUnitMode)
            let converted = convert(dailyGoal, from: oldValue, to: defaultUnitMode)
            dailyGoal = (converted / step).rounded() * step
            userDefaults.set(defaultUnitMode.rawValue, forKey: Keys.defaultUnitMode)
        }
    }

    /// Daily goal expressed in cups (for internal progress calculations)
    var dailyGoalInCups: Double {
        switch defaultUnitMode {
        case .cups: return dailyGoal
        case .oz: return dailyGoal / 8
        case .mL: return dailyGoal / 236.588
        }
    }

    var colorScheme: ColorSchemeOption {
        didSet {
            userDefaults.set(colorScheme.rawValue, forKey: Keys.colorScheme)
        }
    }

    // MARK: Private

    private enum Keys {
        static let dailyGoal = "dailyGoal"
        static let defaultUnitMode = "defaultUnitMode"
        static let colorScheme = "colorScheme"
    }

    private let userDefaults: UserDefaults

    private func convert(_ value: Double, from: UnitMode, to: UnitMode) -> Double {
        let inCups: Double
        switch from {
        case .cups: inCups = value
        case .oz: inCups = value / 8
        case .mL: inCups = value / 236.588
        }
        switch to {
        case .cups: return inCups
        case .oz: return inCups * 8
        case .mL: return inCups * 236.588
        }
    }

    private func stepSize(for unit: UnitMode) -> Double {
        switch unit {
        case .cups: return 1
        case .oz: return 8
        case .mL: return 50
        }
    }
}
