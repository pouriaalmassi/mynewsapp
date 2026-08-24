//
//  mynewsappApp.swift
//  mynewsapp
//
//  Created by Pouria Almassi on 2025-12-07.
//

import SwiftUI

@main
struct mynewsappApp: App {
    init() {
        AppLogger.general.info("App launched and initialized.")
        AppLogger.general.info("Logging system active, capturing debug session trace.")
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: ContentViewModel(
                    newsService: NewsClient()
                )
            )
        }
    }
}
