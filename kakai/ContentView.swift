//
//  ContentView.swift
//  kakai
//
//  Created by musung on 2025/03/16.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var relationship = RelationshipModel()
    @AppStorage("isSetupComplete") private var isSetupComplete = false
    
    var body: some View {
        #if DEBUG
        // In debug mode, always go to main view
        MainView()
            .environmentObject(relationship)
        #else
        if isSetupComplete {
            MainView()
                .environmentObject(relationship)
        } else {
            OnboardingView(isSetupComplete: $isSetupComplete)
                .environmentObject(relationship)
        }
        #endif
    }
}

#Preview {
    ContentView()
}
