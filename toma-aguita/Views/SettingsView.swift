//
//  SettingsView.swift
//  toma-aguita
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @State private var preferences = PreferencesManager.shared

    private var stepperStep: Double {
        switch preferences.defaultUnitMode {
        case .cups: return 1
        case .oz: return 8
        case .mL: return 50
        }
    }

    private var stepperRange: ClosedRange<Double> {
        switch preferences.defaultUnitMode {
        case .cups: return 4 ... 16
        case .oz: return 32 ... 128
        case .mL: return 950 ... 3800
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: preferences.colorScheme.backgroundGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: preferences.colorScheme.gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Settings")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: preferences.colorScheme.gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .padding(.top, 20)

                    VStack(spacing: 16) {
                        // Daily Goal Section
                        SettingCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "target")
                                        .font(.system(size: 20))
                                        .foregroundColor(preferences.colorScheme.primaryColor)
                                    Text("Daily Goal")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }

                                Stepper(value: $preferences.dailyGoal, in: stepperRange, step: stepperStep) {
                                    HStack {
                                        Text("\(Int(preferences.dailyGoal.rounded())) \(preferences.defaultUnitMode.displayName)")
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: preferences.colorScheme.gradientColors,
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        Spacer()
                                    }
                                }
                            }
                        }

                        // Default Unit Section
                        SettingCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "ruler")
                                        .font(.system(size: 20))
                                        .foregroundColor(preferences.colorScheme.primaryColor)
                                    Text("Default Unit")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }

                                Picker("Unit", selection: $preferences.defaultUnitMode) {
                                    ForEach(UnitMode.allCases, id: \.self) { mode in
                                        Text(mode.displayName).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        // Color Scheme Section
                        SettingCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "paintpalette")
                                        .font(.system(size: 20))
                                        .foregroundColor(preferences.colorScheme.primaryColor)
                                    Text("Color Theme")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                }

                                HStack(spacing: 12) {
                                    ForEach(ColorSchemeOption.allCases, id: \.self) { scheme in
                                        ColorSchemeButton(
                                            scheme: scheme,
                                            isSelected: preferences.colorScheme == scheme
                                        ) {
                                            let impact = UIImpactFeedbackGenerator(style: .medium)
                                            impact.impactOccurred()
                                            preferences.colorScheme = scheme
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Setting Card

struct SettingCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            content
        }
        .padding(20)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Color Scheme Button

struct ColorSchemeButton: View {
    let scheme: ColorSchemeOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: scheme.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                }

                Text(scheme.rawValue.components(separatedBy: " & ").first ?? "")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
