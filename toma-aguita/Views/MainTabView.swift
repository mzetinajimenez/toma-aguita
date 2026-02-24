//
//  MainTabView.swift
//  toma-aguita
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var preferences = PreferencesManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Track", systemImage: "drop.fill")
            }
            .tag(0)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "chart.xyaxis.line")
            }
            .tag(1)

            NavigationStack {
                SocialView()
            }
            .tabItem {
                Label("Friends", systemImage: "person.2.fill")
            }
            .tag(2)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(preferences.colorScheme.primaryColor)
    }
}

#Preview {
    MainTabView()
}
