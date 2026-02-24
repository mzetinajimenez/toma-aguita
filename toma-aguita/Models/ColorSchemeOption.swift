//
//  ColorSchemeOption.swift
//  toma-aguita
//

import SwiftUI

enum ColorSchemeOption: String, CaseIterable, Codable {
    case cyan = "Cyan & Blue"
    case purple = "Purple & Pink"
    case green = "Green & Teal"
    case orange = "Orange & Red"

    var primaryColor: Color {
        switch self {
        case .cyan: return .cyan
        case .purple: return .purple
        case .green: return .green
        case .orange: return .orange
        }
    }

    var secondaryColor: Color {
        switch self {
        case .cyan: return .blue
        case .purple: return .pink
        case .green: return .teal
        case .orange: return .red
        }
    }

    var gradientColors: [Color] {
        [primaryColor, secondaryColor]
    }

    var backgroundGradientColors: [Color] {
        [primaryColor.opacity(0.2), secondaryColor.opacity(0.1)]
    }

    var buttonGradientColors: [Color] {
        [primaryColor.opacity(0.2), secondaryColor.opacity(0.2)]
    }
}
