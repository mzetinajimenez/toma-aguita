//
//  MainTabView.swift
//  toma-aguita
//
//  Created by Claude Code
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ContentView()
                    .navigationTitle("💧 Toma Aguita")
                    .navigationBarTitleDisplayMode(.inline)
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
        }
        .tint(.cyan)
    }
}

#Preview {
    MainTabView()
}
