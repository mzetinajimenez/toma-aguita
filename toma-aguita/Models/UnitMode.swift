//
//  UnitMode.swift
//  toma-aguita

import Foundation

enum UnitMode: String, Codable, CaseIterable {
    case cups
    case oz
    case mL

    // MARK: Internal

    var displayName: String {
        switch self {
        case .cups: return "Cups"
        case .oz: return "Oz"
        case .mL: return "mL"
        }
    }
}
