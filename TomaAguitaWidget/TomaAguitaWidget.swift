//
//  TomaAguitaWidget.swift
//  TomaAguitaWidget
//
//  Created by Claude Code
//

import SwiftData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> WaterIntakeEntry {
        WaterIntakeEntry(date: Date(), cupsConsumed: 0, dailyGoal: PreferencesManager.shared.dailyGoal, unitMode: PreferencesManager.shared.defaultUnitMode)
    }

    func getSnapshot(in _: Context, completion: @escaping (WaterIntakeEntry) -> Void) {
        let entry = WaterIntakeEntry(date: Date(), cupsConsumed: 3, dailyGoal: PreferencesManager.shared.dailyGoal, unitMode: PreferencesManager.shared.defaultUnitMode)
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<WaterIntakeEntry>) -> Void) {
        let currentDate = Date()
        let cupsConsumed = fetchTodayWaterIntake()

        let entry = WaterIntakeEntry(
            date: currentDate,
            cupsConsumed: cupsConsumed,
            dailyGoal: PreferencesManager.shared.dailyGoal,
            unitMode: PreferencesManager.shared.defaultUnitMode
        )

        // Update timeline every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchTodayWaterIntake() -> Double {
        do {
            // Get shared container URL for App Group
            guard let sharedURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.mzj.toma-aguita"
            ) else {
                print("Widget: Failed to get App Group container")
                return 0
            }

            // Configure SwiftData to use shared container
            let storeURL = sharedURL.appendingPathComponent("TomaAguita.sqlite")
            let config = ModelConfiguration(url: storeURL)
            let container = try ModelContainer(for: WaterIntakeRecord.self, configurations: config)
            let context = ModelContext(container)

            let today = Calendar.current.startOfDay(for: Date())
            let descriptor = FetchDescriptor<WaterIntakeRecord>(
                predicate: #Predicate { record in
                    record.date >= today
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )

            let records = try context.fetch(descriptor)
            if let todayRecord = records.first(where: { $0.isToday }) {
                return todayRecord.cupsConsumed
            }
        } catch {
            print("Widget: Error fetching water intake: \(error)")
        }

        return 0
    }
}

struct WaterIntakeEntry: TimelineEntry {
    let date: Date
    let cupsConsumed: Double
    let dailyGoal: Double // in current unit
    let unitMode: UnitMode

    var progress: Double {
        let consumedInUnit: Double
        switch unitMode {
        case .cups: consumedInUnit = cupsConsumed
        case .oz: consumedInUnit = cupsConsumed * 8
        case .mL: consumedInUnit = cupsConsumed * 236.588
        }
        return min(consumedInUnit / dailyGoal, 1.0)
    }
}

struct TomaAguitaWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Background
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Circular progress
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 5)

                // Progress circle
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(Color.blue.opacity(0.9), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                // Center content
                VStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.cyan.opacity(0.8))

                    Text(entry.cupsConsumed.truncatingRemainder(dividingBy: 1) == 0
                        ? "\(Int(entry.cupsConsumed))"
                        : String(format: "%.1f", entry.cupsConsumed))
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(4)
        }
    }
}

struct TomaAguitaWidget: Widget {
    let kind: String = "TomaAguitaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TomaAguitaWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Water Intake")
        .description("Track your daily water consumption")
        .supportedFamilies([.accessoryCircular])
    }
}

#Preview(as: .accessoryCircular) {
    TomaAguitaWidget()
} timeline: {
    WaterIntakeEntry(date: .now, cupsConsumed: 3, dailyGoal: 8, unitMode: .cups)
    WaterIntakeEntry(date: .now, cupsConsumed: 6, dailyGoal: 8, unitMode: .cups)
    WaterIntakeEntry(date: .now, cupsConsumed: 8, dailyGoal: 8, unitMode: .cups)
}
