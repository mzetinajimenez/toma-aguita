//
//  HistoryView.swift
//  toma-aguita
//

import SwiftUI

struct HistoryView: View {
    // MARK: Internal

    var body: some View {
        ZStack {
            LinearGradient(
                colors: preferences.colorScheme.backgroundGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: preferences.colorScheme.gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                VStack(spacing: 12) {
                    Text("📊 Your Journey")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: preferences.colorScheme.gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("Your hydration history will appear here!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Keep tracking daily to see your progress over time")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 40)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @State private var preferences = PreferencesManager.shared
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
