//
//  Reminders_AppApp.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import SwiftUI

@main
struct Reminders_AppApp: App {
    @StateObject var manager =  ReminderManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


