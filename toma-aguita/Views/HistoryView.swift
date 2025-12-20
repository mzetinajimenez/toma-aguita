//
//  HistoryView.swift
//  toma-aguita
//
//  Created by Claude Code
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        ZStack {
            // Background gradient matching ContentView
            LinearGradient(
                colors: [Color.cyan.opacity(0.2), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                VStack(spacing: 12) {
                    Text("📊 Your Journey")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Your hydration history will appear here!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Keep tracking daily to see your progress over time")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
