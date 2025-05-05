//
//  ReminderManager.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import Foundation
import SwiftUI

class ReminderManager: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Environment(\.colorScheme) var colorScheme
    
    let saveKey = "reminders"
    
    init() {
        loadReminders()
        addReminder(reminder: Reminder(
                name: "test",
                iconName: "tshirt.fill",
                colour: RGBColor(
                    r: 255,
                    g: 0,
                    b: 0
                ),
                startDate: Date(),
                goalDate: Date().addingTimeInterval(120)
            )
        )
    }
    
    func addReminder(reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
    }
    
    func removeReminder(id: UUID) {
        reminders.removeAll { $0.id == id}
        saveReminders()
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
            reminders = decoded
        }
    }
}


