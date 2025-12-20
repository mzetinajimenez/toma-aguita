//
//  SocialView.swift
//  toma-aguita
//
//  Created by Claude Code
//

import SwiftUI

struct SocialView: View {
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
                Image(systemName: "person.2.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                VStack(spacing: 12) {
                    Text("👥 Stay Accountable Together")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Connect with friends to stay hydrated together!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Coming soon: Share progress and cheer each other on")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SocialView()
    }
}
