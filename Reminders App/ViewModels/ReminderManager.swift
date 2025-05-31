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
        calculateNotifications()
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
            
            dirty = true
            reminders[i] = r
        }
        
        if dirty { saveReminders() }
    }
    
    func addReminder(reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
        calculateNotifications()
    }
    
    func removeReminder(id: UUID) {
        reminders.removeAll { $0.id == id}
        saveReminders()
        removeNotificationsFor(reminderID: id)
        calculateNotifications()
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
        
        let r = reminders[index]
        r.complete = true
        
        if r.repeatTrigger == .afterCompletion,
           let next = r.nextDueDate(from: Date()) {
                
                r.complete = false
                r.startDate = Date()
                r.goalDate = next
                
                removeNotificationsFor(reminderID: r.id)
                
        }
        
        reminders[index] = r
        saveReminders()
    }
    func editReminder(id: UUID, newReminder: Reminder) {
        if let index = reminders.firstIndex(where: {$0.id == id}) {
            reminders[index] = newReminder
            reminders = reminders
            saveReminders()
            calculateNotifications()
        }
    }
    
    private func scheduleNotification(at fireDate: Date, body: String) -> UUID {
        let content = UNMutableNotificationContent()
        content.title = "Reminder due"
        content.body = body
        content.sound = UNNotificationSound.default
        let id = UUID()
        
        
        
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error)")
            }
        }
        return id
    }
    
    func generateNotificationBody(reminderID: UUID, offset: TimeInterval) -> String {
        guard let index = reminders.firstIndex(where: {$0.id == reminderID}) else {return ""}
        let reminder = reminders[index]
        
        return "Your reminder \(reminder.name) is due \(offset == 0 ? "" : "in \(Int(offset / 60)) minute \(Int(offset / 60) == 1 ? "" : "s")")"
    }
    
    private func calculateNotifications() {
        let now = Date()
        
        var userNotificationTimes: [(Date, UUID, TimeInterval)] = []
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
                    userNotificationTimes.append((dueDate.addingTimeInterval(-notificationTime), reminder.id, notificationTime))
                    
                    
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

        
        
        var uncutRepeatingNotificationTimes: [(Date, UUID, TimeInterval)] = []
        
        let freeSpace: Int = 64
        
        for time in repeatingUserNotificationTimes {
            let reminderID = time.0
            let notificationTime = time.1
            let repeatInterval = time.2
            guard let index = reminders.firstIndex(where: {$0.id == reminderID}) else {continue}
            let r = reminders[index]
            let baseDate = r.goalDate
            
            for i in 0...freeSpace {
                let asdf = baseDate.addingTimeInterval(-notificationTime + (Double(i) * repeatInterval))
                uncutRepeatingNotificationTimes.append((asdf,reminderID, notificationTime))
            }
        }
        var existingNotifications: [(Date,String,String)] = []
        let group = DispatchGroup()
        group.enter()
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let fireDate = Calendar.current.date(from: trigger.dateComponents) {
                    existingNotifications.append((fireDate, request.content.body, request.identifier))
                }
            }
            group.leave()
        }
        group.wait()
        //let preExistingNotifications = UNUserNotificationCenter.current()
        
        let desiredNotifications = uncutRepeatingNotificationTimes + userNotificationTimes
            .filter { $0.0 > now }
            .sorted { $0.0 < $1.0 }
            .prefix(freeSpace)
        
        for notification in existingNotifications {
            let exists = desiredNotifications.contains { desired in
                desired.0 == notification.0 &&
                generateNotificationBody(reminderID: desired.1, offset: desired.2) == notification.1
            }
            if !exists {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.2])
            }
        }
         
        for notification in desiredNotifications {
            let exists = existingNotifications.contains { existing in
                existing.0 == notification.0 &&
                existing.1 == generateNotificationBody(reminderID: notification.1, offset: notification.2)
            }
            if !exists {
                let body = generateNotificationBody(reminderID: notification.1, offset: notification.2)
                let id = scheduleNotification(at: notification.0, body: body)
                print("Current time is: \(now), notification Scheduled at: \(notification.0) with body: \(body) and id: \(id)")
                if let index = reminders.firstIndex(where: {$0.id == notification.1}) {
                    let r = reminders[index]
                    if !r.notificationIDs.contains(id) {
                        r.notificationIDs.append(id)
                    }
                    reminders[index] = r
                }
            }
        }
        
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


