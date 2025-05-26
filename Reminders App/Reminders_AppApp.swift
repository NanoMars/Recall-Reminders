//
//  Reminders_AppApp.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import SwiftUI
import Toasts

@main
struct Reminders_AppApp: App {
    @StateObject var reminderManager =  ReminderManager()
    @StateObject var viewManager =  ViewManager()
    var body: some Scene {
        WindowGroup {
            ContentView(settings: SettingsManager.shared)
                .environmentObject(viewManager)
                .environmentObject(reminderManager)
                .installToast(position: .bottom)
        }
    }
}


