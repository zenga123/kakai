//
//  ThemeManager.swift
//  kakai
//
//  Created for kakai app.
//

import SwiftUI

// 앱 전체에서 테마 설정을 관리하는 클래스
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
}
