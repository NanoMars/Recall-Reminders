//
//  ReminderManager.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class ReminderManager: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Environment(\.colorScheme) var colorScheme
    var tagCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for reminder in reminders {
            for tag in reminder.tags {
                counts[tag, default: 0] += 1
            }
        }
        return Dictionary(uniqueKeysWithValues: counts.sorted {
            if $0.value == $1.value {
                return $0.key < $1.key
            }
            return $0.value > $1.value
        })
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    let saveKey = "reminders"
    
    init() {
        loadReminders()
    }
    
    func addReminder(reminder: Reminder) {
        reminders.append(reminder)
        
        saveReminders()
        //scheduleNotification(for: reminder)
    }
    
    func removeReminder(id: UUID) {
        reminders.removeAll { $0.id == id}
        saveReminders()
        removeNotificationsFor(reminderID: id)
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
    
    func markComplete(id: UUID) {
        if let index = reminders.firstIndex(where: {$0.id == id}) {
            reminders[index].complete = true
            reminders = reminders
            saveReminders()
        }
    }
    func editReminder(id: UUID, newReminder: Reminder) {
        if let index = reminders.firstIndex(where: {$0.id == id}) {
            reminders[index] = newReminder
            reminders = reminders
            saveReminders()
        }
    }
    
    func scheduleNotification(for reminder: Reminder, offset: TimeInterval) -> UUID {
        let content = UNMutableNotificationContent()
        content.title = "Reminder due"
        content.body = "Your reminder \(reminder.name) is due"
        content.sound = UNNotificationSound.default 
        let id = UUID()
        
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.goalDate.addingTimeInterval(-offset))
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error)")
            }
        }
        return id
    }
    
    func removeNotificationsFor(reminderID: UUID) {
        if let index = reminders.firstIndex(where: {$0.id == reminderID}) {
            
            let reminder = reminders[index]
            let identifiers = reminder.notificationIDs.map {$0.uuidString}
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func hasNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized,   .provisional, .ephemeral:
                    completion(true)
                case .denied, .notDetermined:
                    completion(false)
                @unknown default:
                    completion(false)
                }
            }
        }
    }
}


