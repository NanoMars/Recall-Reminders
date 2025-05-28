//
//  Reminders_AppApp.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import SwiftUI
import Toasts
import OnboardingKit

@main
struct Reminders_AppApp: App {
    @StateObject var reminderManager =  ReminderManager()
    @StateObject var viewManager =  ViewManager()
    @StateObject var settings = SettingsManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView(settings: SettingsManager.shared)
                .environmentObject(viewManager)
                .environmentObject(reminderManager)
                .preferredColorScheme(colorSchemeFromTheme(settings.theme))
                .showOnboardingIfNeeded(using: .prod)
                .installToast(position: .bottom)
        }
    }
    
    private func colorSchemeFromTheme(_ theme: AppTheme) -> ColorScheme? {
        switch theme {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
}


