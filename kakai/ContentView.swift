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
        if isSetupComplete {
            MainView()
                .environmentObject(relationship)
        } else {
            SetupView(isSetupComplete: $isSetupComplete)
                .environmentObject(relationship)
        }
    }
}

#Preview {
    ContentView()
}
