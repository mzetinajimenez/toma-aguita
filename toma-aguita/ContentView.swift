//
//  ContentView.swift
//  toma-aguita
//
//  Created by Marvin Zetina on 11/15/25.
//

import SwiftUI
import SwiftData
import WidgetKit

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
                        cupsConsumed: Binding(
                            get: { manager.cupsConsumed },
                            set: { newValue in
                                manager.currentRecord?.cupsConsumed = max(0, newValue)
                                try? modelContext.save()
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        ),
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
    @Binding var cupsConsumed: Double
    let dailyGoal: Double
    let unitMode: UnitMode

    @State private var isDragging: Bool = false
    @State private var dragProgress: Double = 0
    @State private var lastSnappedCups: Double = 0
    @State private var impactGenerator = UIImpactFeedbackGenerator(style: .light)

    var progress: Double {
        isDragging ? dragProgress : min(cupsConsumed / dailyGoal, 1.0)
    }

    private func roundToNearestHalf(_ value: Double) -> Double {
        return round(value * 2) / 2
    }

    var displayValue: Double {
        // Use drag progress when dragging, otherwise use actual cupsConsumed
        let currentCups = isDragging ? snappedCups(fromProgress: dragProgress) : cupsConsumed
        switch unitMode {
        case .cups:
            return currentCups
        case .oz:
            return currentCups * 8
        case .mL:
            return currentCups * 240
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

    // Convert drag location to angle (0-360 degrees)
    private func angleFromLocation(_ location: CGPoint, in size: CGSize) -> Double {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let vector = CGPoint(x: location.x - center.x, y: location.y - center.y)
        let angleRadians = atan2(vector.y, vector.x)
        let angleDegrees = (angleRadians * 180 / .pi + 90).truncatingRemainder(dividingBy: 360)
        return angleDegrees < 0 ? angleDegrees + 360 : angleDegrees
    }

    // Get increment size for current unit mode
    private func incrementInCups() -> Double {
        switch unitMode {
        case .cups: return 0.25
        case .oz: return 0.125  // 1 oz = 1/8 cup
        case .mL: return 10.0 / 240.0  // 10 mL in cups
        }
    }

    // Snap progress to nearest increment
    private func snappedCups(fromProgress rawProgress: Double) -> Double {
        let cupsFromProgress = rawProgress * dailyGoal
        let increment = incrementInCups()
        return round(cupsFromProgress / increment) * increment
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.cyan.opacity(0.2), lineWidth: 24)

                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: cupsConsumed > dailyGoal ? [.orange, .yellow] : [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 24, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        isDragging
                            ? nil  // No animation during drag for immediate response
                            : .spring(response: 0.6, dampingFraction: 0.8),
                        value: progress
                    )

                // Center content
            VStack(spacing: 8) {
                Text({
                    // For cups, round to nearest 0.25
                    let value = unitMode == .cups ? round(displayValue * 4) / 4 : displayValue
                    // Check if it's a whole number
                    return abs(value - round(value)) < 0.01
                        ? "\(Int(round(value)))"
                        : String(format: unitMode == .cups ? "%.2f" : "%.1f", value)
                }())
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
            } // Close ZStack
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            impactGenerator.prepare()
                            lastSnappedCups = cupsConsumed
                        }

                        let angle = angleFromLocation(value.location, in: geometry.size)
                        let rawProgress = angle / 360.0
                        dragProgress = rawProgress

                        let snapped = snappedCups(fromProgress: rawProgress)

                        // Haptic feedback on increment snap
                        if snapped != lastSnappedCups {
                            impactGenerator.impactOccurred(intensity: 0.5)
                            lastSnappedCups = snapped

                            // Success haptic when crossing goal threshold
                            let prevProgress = (lastSnappedCups - incrementInCups()) / dailyGoal
                            let currProgress = snapped / dailyGoal
                            if prevProgress < 1.0 && currProgress >= 1.0 {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                        }
                    }
                    .onEnded { _ in
                        isDragging = false

                        // Update binding with final snapped value
                        let finalCups = snappedCups(fromProgress: dragProgress)
                        cupsConsumed = max(0, min(finalCups, 16.0))  // Cap at 16 cups max
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Water intake tracker")
            .accessibilityValue("\(Int(cupsConsumed)) of \(Int(dailyGoal)) cups consumed")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    cupsConsumed = min(cupsConsumed + incrementInCups(), 16.0)
                case .decrement:
                    cupsConsumed = max(cupsConsumed - incrementInCups(), 0)
                @unknown default:
                    break
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
