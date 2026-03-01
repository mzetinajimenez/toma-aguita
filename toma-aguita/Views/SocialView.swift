//
//  SocialView.swift
//  toma-aguita
//

import SwiftUI

struct SocialView: View {
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
                Image(systemName: "person.2.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: preferences.colorScheme.gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                VStack(spacing: 12) {
                    Text("👥 Stay Accountable Together")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: preferences.colorScheme.gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("Connect with friends to stay hydrated together!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Coming soon: Share progress and cheer each other on")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 40)
            }
        }
        .navigationTitle("Friends")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @State private var preferences = PreferencesManager.shared
}

#Preview {
    NavigationStack {
        SocialView()
    }
}
