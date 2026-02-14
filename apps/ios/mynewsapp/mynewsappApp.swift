//
//  mynewsappApp.swift
//  mynewsapp
//
//  Created by Pouria Almassi on 2025-12-07.
//

import SwiftUI

@main
struct mynewsappApp: App {
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
