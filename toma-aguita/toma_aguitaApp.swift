//
//  toma_aguitaApp.swift
//  toma-aguita
//
//  Created by Marvin Zetina on 11/15/25.
//

import SwiftData
import SwiftUI

@main
struct toma_aguitaApp: App {
    // MARK: Lifecycle

    init() {
        do {
            // Get shared container URL for App Group
            guard let sharedURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.mzj.toma-aguita"
            ) else {
                fatalError("Failed to get App Group container")
            }

            // Configure SwiftData to use shared container
            let storeURL = sharedURL.appendingPathComponent("TomaAguita.sqlite")
            let config = ModelConfiguration(url: storeURL)

            modelContainer = try ModelContainer(
                for: WaterIntakeRecord.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    // MARK: Internal

    let modelContainer: ModelContainer

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(modelContainer)
        }
    }
}
