//
//  ContentView.swift
//  toma-aguita
//
//  Created by Marvin Zetina on 11/15/25.
//

import SwiftUI
import SwiftData

enum UnitMode {
    case cups
    case oz
    case mL

    var displayName: String {
        switch self {
        case .cups: return "Cups"
        case .oz: return "Oz"
        case .mL: return "mL"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var manager: WaterIntakeManager?
    @State private var showResetConfirmation = false
    @State private var previousProgress: Double = 0
    @State private var unitMode: UnitMode = .cups

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Title
                Text("💧 Toma Aguita")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, -10)

                // Unit toggle
                Picker("Unit", selection: $unitMode) {
                    Text("Cups").tag(UnitMode.cups)
                    Text("Oz").tag(UnitMode.oz)
                    Text("mL").tag(UnitMode.mL)
                }
                .pickerStyle(.segmented)
                .frame(width: 280)

                Spacer()

                // Circular Progress
                if let manager = manager {
                    CircularProgressView(
                        progress: manager.progress,
                        cupsConsumed: manager.cupsConsumed,
                        dailyGoal: WaterIntakeManager.dailyGoal,
                        unitMode: unitMode
                    )
                    .frame(width: 250, height: 250)
                }

                Spacer()

                // Add Water Buttons
                VStack(spacing: 20) {
                    HStack(spacing: 15) {
                        AddWaterButton(
                            amount: 0.5,
                            label: labelForAmount(0.5),
                            unitMode: unitMode,
                            iconType: .half
                        ) {
                            addWater(0.5)
                        }
                        AddWaterButton(
                            amount: 1.0,
                            label: labelForAmount(1.0),
                            unitMode: unitMode,
                            iconType: .one
                        ) {
                            addWater(1.0)
                        }
                        AddWaterButton(
                            amount: 2.0,
                            label: labelForAmount(2.0),
                            unitMode: unitMode,
                            iconType: .two
                        ) {
                            addWater(2.0)
                        }
                    }

                    // Remove and Reset buttons
                    HStack(spacing: 15) {
                        Button(action: { removeWater(1.0) }) {
                            HStack {
                                Image(systemName: "minus.circle.fill")
                                Text("Remove \(labelForAmount(1.0, includeSign: false))")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(16)
                        }

                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                Text("Reset")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.gray)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .onAppear {
            if manager == nil {
                manager = WaterIntakeManager(modelContext: modelContext)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Check for midnight reset when app becomes active
                manager?.checkForMidnightReset()
            }
        }
        .confirmationDialog(
            "Reset Today's Water Intake?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset to 0", role: .destructive) {
                resetToday()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func labelForAmount(_ cups: Double, includeSign: Bool = true) -> String {
        let sign = includeSign ? "+" : ""
        switch unitMode {
        case .cups:
            return cups.truncatingRemainder(dividingBy: 1) == 0 ? "\(sign)\(Int(cups))" : "\(sign)\(cups)"
        case .oz:
            let oz = cups * 8
            return "\(sign)\(Int(oz))"
        case .mL:
            let mL = cups * 240
            return "\(sign)\(Int(mL))"
        }
    }

    private func addWater(_ cups: Double) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        previousProgress = manager?.progress ?? 0
        manager?.addWater(cups: cups)

        // Celebrate when reaching the goal
        if previousProgress < 1.0 && (manager?.progress ?? 0) >= 1.0 {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        }
    }

    private func removeWater(_ cups: Double) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        manager?.removeWater(cups: cups)
    }

    private func resetToday() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.warning)
        manager?.resetToday()
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    let cupsConsumed: Double
    let dailyGoal: Double
    let unitMode: UnitMode

    private func roundToNearestHalf(_ value: Double) -> Double {
        return round(value * 2) / 2
    }

    var displayValue: Double {
        let roundedCups = roundToNearestHalf(cupsConsumed)
        switch unitMode {
        case .cups:
            return roundedCups
        case .oz:
            return roundedCups * 8
        case .mL:
            return roundedCups * 240
        }
    }

    var displayGoal: Double {
        switch unitMode {
        case .cups:
            return dailyGoal
        case .oz:
            return dailyGoal * 8
        case .mL:
            return dailyGoal * 240
        }
    }

    var unitLabel: String {
        switch unitMode {
        case .cups:
            return "cups"
        case .oz:
            return "oz"
        case .mL:
            return "mL"
        }
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.cyan.opacity(0.2), lineWidth: 24)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)

            // Center content
            VStack(spacing: 8) {
                Text(displayValue.truncatingRemainder(dividingBy: 1) == 0
                     ? "\(Int(displayValue))"
                     : String(format: "%.1f", displayValue))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("of \(Int(displayGoal)) \(unitLabel)")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)

                if progress >= 1.0 {
                    Text("🎉 Goal Reached!")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
            }
        }
    }
}

// MARK: - Add Water Button
enum DropIconType {
    case half, one, two
}

struct AddWaterButton: View {
    let amount: Double
    let label: String
    let unitMode: UnitMode
    let iconType: DropIconType
    let action: () -> Void

    var unitLabel: String {
        switch unitMode {
        case .cups:
            return "cup\(amount > 1 ? "s" : "")"
        case .oz:
            return "oz"
        case .mL:
            return "mL"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Group {
                    switch iconType {
                    case .half:
                        Image(systemName: "drop.halffull")
                            .font(.system(size: 24))
                    case .one:
                        Image(systemName: "drop.fill")
                            .font(.system(size: 24))
                    case .two:
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 20))
                            Image(systemName: "drop.fill")
                                .font(.system(size: 20))
                        }
                    }
                }
                Text(label)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text(unitLabel)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .opacity(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.cyan, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.cyan.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WaterIntakeRecord.self, inMemory: true)
}
