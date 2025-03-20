//
//  kakaiApp.swift
//  kakai
//
//  Created by musung on 2025/03/16.
//

import SwiftUI

@main
struct kakaiApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
