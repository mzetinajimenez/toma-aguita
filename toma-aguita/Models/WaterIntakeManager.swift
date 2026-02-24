//
//  WaterIntakeManager.swift
//  toma-aguita

import Foundation
import SwiftData
import SwiftUI
import WidgetKit

@Observable
class WaterIntakeManager {
    private let preferences = PreferencesManager.shared
    private var modelContext: ModelContext
    var currentRecord: WaterIntakeRecord?

    var dailyGoal: Double {
        preferences.dailyGoal
    }

    var cupsConsumed: Double {
        currentRecord?.cupsConsumed ?? 0
    }

    var progress: Double {
        min(cupsConsumed / preferences.dailyGoalInCups, 1.0)
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateTodayRecord()
        checkForMidnightReset()
    }

    /// Load today's record or create a new one
    private func loadOrCreateTodayRecord() {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<WaterIntakeRecord>(
            predicate: #Predicate { record in
                record.date >= today
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            let records = try modelContext.fetch(descriptor)
            if let todayRecord = records.first(where: { $0.isToday }) {
                currentRecord = todayRecord
            } else {
                // Create new record for today
                let newRecord = WaterIntakeRecord()
                modelContext.insert(newRecord)
                currentRecord = newRecord
                try modelContext.save()
            }
        } catch {
            print("Error loading today's record: \(error)")
            // Create a fallback record
            let newRecord = WaterIntakeRecord()
            modelContext.insert(newRecord)
            currentRecord = newRecord
        }
    }

    /// Check if we need to reset for a new day
    func checkForMidnightReset() {
        guard let record = currentRecord else { return }

        if !record.isToday {
            // It's a new day! Load or create today's record
            loadOrCreateTodayRecord()
        }
    }

    /// Add cups to today's intake
    func addWater(cups: Double) {
        guard let record = currentRecord else { return }

        record.cupsConsumed = max(0, record.cupsConsumed + cups)
        saveContext()
    }

    /// Remove cups from today's intake
    func removeWater(cups: Double) {
        guard let record = currentRecord else { return }

        record.cupsConsumed = max(0, record.cupsConsumed - cups)
        saveContext()
    }

    /// Reset today's count to zero
    func resetToday() {
        guard let record = currentRecord else { return }

        record.cupsConsumed = 0
        saveContext()
    }

    /// Get historical records (for future features)
    func getHistory(days: Int = 7) -> [WaterIntakeRecord] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let descriptor = FetchDescriptor<WaterIntakeRecord>(
            predicate: #Predicate { record in
                record.date >= startDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching history: \(error)")
            return []
        }
    }

    private func saveContext() {
        do {
            try modelContext.save()
            // Notify widget to refresh immediately
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
