//
//  WaterIntakeRecord.swift
//  toma-aguita
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@Model
final class WaterIntakeRecord {
    var date: Date
    var cupsConsumed: Double

    init(date: Date = Date(), cupsConsumed: Double = 0) {
        self.date = date
        self.cupsConsumed = cupsConsumed
    }

    /// Returns true if this record is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Returns a normalized date (start of day) for grouping
    var normalizedDate: Date {
        Calendar.current.startOfDay(for: date)
    }
}
