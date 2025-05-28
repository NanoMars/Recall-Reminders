//
//  SettingsManager.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 26/5/2025.
//

import Foundation
import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case dark
    case light
    
    var id: String { self.rawValue }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "theme")
            print("theme updates to \(theme)")
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "theme"),
           let value = AppTheme(rawValue: saved) {
            self.theme = value
        } else {
            self.theme = .system
        }
    }
}
