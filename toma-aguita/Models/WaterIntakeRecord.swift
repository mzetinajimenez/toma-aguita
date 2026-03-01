//
//  WaterIntakeRecord.swift
//  toma-aguita
//

import Foundation
import SwiftData

@Model
final class WaterIntakeRecord {
    // MARK: Lifecycle

    init(date: Date = Date(), cupsConsumed: Double = 0) {
        self.date = date
        self.cupsConsumed = cupsConsumed
    }

    // MARK: Internal

    var date: Date
    var cupsConsumed: Double

    /// Returns true if this record is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Returns a normalized date (start of day) for grouping
    var normalizedDate: Date {
        Calendar.current.startOfDay(for: date)
    }
}
