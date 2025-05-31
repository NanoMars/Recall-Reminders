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
        startRepeatTimer()
    }
    
    private func startRepeatTimer() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
               self?.handleAutoRepeats()
            }
            .store(in: &cancellables)
    }
    
    private func handleAutoRepeats() {
        let now = Date()
        var dirty = false
        
        
        for i in reminders.indices {
            let r = reminders[i]
            guard r.repeatTrigger == .atDueDate,
                  r.goalDate <= now,
                  let next = r.nextDueDate(from: r.goalDate)
            else { continue }
            
            removeNotificationsFor(reminderID: r.id)
            r.startDate = r.goalDate
            r.goalDate = next
            r.notificationIDs = [scheduleNotification(for: r, offset: 0)]
            
            dirty = true
            reminders[i] = r
        }
        
        if dirty { saveReminders() }
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
        /*
        if let index = reminders.firstIndex(where: {$0.id == id}) {
            reminders[index].complete = true
            reminders = reminders
            saveReminders()
        }*/
        
        guard let index = reminders.firstIndex(where: {$0.id == id}) else {return}
        
        var r = reminders[index]
        r.complete = true
        
        if r.repeatTrigger == .afterCompletion,
           let next = r.nextDueDate(from: Date()) {
                
                r.complete = false
                r.startDate = Date()
                r.goalDate = next
                
                removeNotificationsFor(reminderID: r.id)
                
                r.notificationIDs = [scheduleNotification(for: r, offset: 0)]
        }
        
        reminders[index] = r
        saveReminders()
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
        content.body = "Your reminder \(reminder.name) is due \(offset == 0 ? "" : "in \(Int(offset / 60)) minute \(Int(offset / 60) == 1 ? "" : "s")")"
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
    
    private func calculateNotifications() {
        let now = Date()
        
        var userNotificationTimes: [TimeInterval] = []
        var repeatingUserNotificationTimes: [(UUID, TimeInterval, TimeInterval)] = []
        var userNotificationIDs: [UUID] = []
        var generatedNotificationIDs: [UUID] = []
        
        for reminder in reminders {
            let dueDate = reminder.goalDate
            var absoluteUserNotificationTimes: [Date] = []
            let repeating: Bool = reminder.repeatTrigger == .atDueDate
            var repeatInterval: TimeInterval = 0
            
            let repeatRule = reminder.repeatRule
            if repeating,
               let unit = reminder.repeatRule?.unit,
               let value = repeatRule?.value {
                switch unit {
                case .minute:
                    repeatInterval = TimeInterval(value * 60)
                case .hour:
                    repeatInterval = TimeInterval(value * 60 * 60)
                case .day:
                    repeatInterval = TimeInterval(value * 60 * 60 * 24)
                case .week:
                    repeatInterval = TimeInterval(value * 60 * 60 * 24 * 7)
                case .month:
                    repeatInterval = TimeInterval(value * 60 * 60 * 24 * 7 * 30)
                case .year:
                    repeatInterval = TimeInterval(value * 60 * 60 * 24 * 7 * 30 * 365)
                }
            }
            
            for notificationTime in reminder.notificationTimes {
                
                if repeating {
                    repeatingUserNotificationTimes.append((reminder.id, notificationTime, repeatInterval))
                    
                } else {
                    userNotificationTimes.append(notificationTime)
                    
                }
                absoluteUserNotificationTimes.append(dueDate.addingTimeInterval(-notificationTime))
            }
            
            for notificationId in reminder.notificationIDs {
                // let notificationDate: Date = ...
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    let UUIDString = notificationId.uuidString
                    if let request = requests.first(where: {$0.identifier == UUIDString}),
                       let callTrigger = request.trigger as? UNCalendarNotificationTrigger {
                        if let fireDate = Calendar.current.date(from: callTrigger.dateComponents),
                           absoluteUserNotificationTimes.contains(fireDate) {
                            userNotificationIDs.append(notificationId)
                        } else {
                            generatedNotificationIDs.append(notificationId)
                        }
                    } else {
                        print("notification not valid, remove it from reminder")
                    }
                    
                }
                
            }
        }
        var uncutRepeatingNotificationTimes: [(Date, UUID)] = []
        
        for time in repeatingUserNotificationTimes {
            let reminderID = time.0
            let notificationTime = time.1
            let repeatInterval = time.2
            guard let index = reminders.firstIndex(where: {$0.id == reminderID}) else {continue}
            let r = reminders[index]
            let baseDate = r.goalDate
            
            for i in 0..<64 {
                let asdf = baseDate.addingTimeInterval(-notificationTime + (Double(i) * repeatInterval))
                uncutRepeatingNotificationTimes.append((asdf,reminderID))
            }
        }
        
        let cutRepeatingNotificationTimes = uncutRepeatingNotificationTimes
            .filter { $0.0 > now }
            .sorted { $0.0 < $1.0 }
            .prefix(64)
        
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
    
    func resetToDefaults() {
        reminders.removeAll()
        saveReminders()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}


