//
//  Reminder.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import Foundation

struct RGBColor: Codable, Equatable {
    var r: Double
    var g: Double
    var b: Double
}

enum RepeatTrigger: String, CaseIterable, Codable, Identifiable {
    case atDueDate
    case afterCompletion
    case none
    var id: String { rawValue }
}

enum RepeatUnit: String, CaseIterable, Codable {
    case minute, hour, day, week, month, year
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .minute:
            return .minute
        case .hour:
            return .hour
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month:
            return .month
        case .year:
            return .year
        }
    }
}

struct RepeatRule: Codable, Equatable {
    var value: Int
    var unit: RepeatUnit
}


final class Reminder: ObservableObject, Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    @Published var name: String
    @Published var iconName: String
    @Published var colour: RGBColor
    @Published var startDate: Date
    @Published var goalDate: Date
    @Published var complete: Bool
    @Published var tags: [String]
    @Published var notificationTimes: [TimeInterval]
    @Published var notificationIDs: [UUID]
    @Published var repeatTrigger: RepeatTrigger
    @Published var repeatRule: RepeatRule?
    
    enum CodingKeys: String, CodingKey {
        case id, name, iconName, colour, startDate, goalDate, complete, tags, notificationIDs
        case repeatTrigger, repeatRule
        case notificationTimes
    }
    
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(iconName, forKey: .iconName)
        try container.encode(colour, forKey: .colour)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(goalDate, forKey: .goalDate)
        try container.encode(complete, forKey: .complete)
        try container.encode(tags, forKey: .tags)
        try container.encode(notificationTimes, forKey: .notificationTimes)
        try container.encode(notificationIDs, forKey: .notificationIDs)
        try container.encode(repeatTrigger, forKey: .repeatTrigger)
        try container.encode(repeatRule, forKey: .repeatRule)
    }
    
    required init(from decoder: Decoder) throws {
        let  container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        iconName = try container.decode(String.self, forKey: .iconName)
        colour = try container.decode(RGBColor.self, forKey: .colour)
        startDate = try container.decode(Date.self, forKey: .startDate)
        goalDate = try container.decode(Date.self, forKey: .goalDate)
        complete = try container.decode(Bool.self, forKey: .complete)
        tags = try container.decode([String].self, forKey: .tags)
        notificationTimes = try container.decode([TimeInterval].self, forKey: .notificationTimes)
        notificationIDs = try container.decode([UUID].self, forKey: .notificationIDs)
        repeatTrigger = try container.decodeIfPresent(RepeatTrigger.self, forKey: .repeatTrigger) ?? .none
        repeatRule = try container.decodeIfPresent(RepeatRule.self, forKey: .repeatRule)
    }
    
    static func == (lhs: Reminder, rhs: Reminder ) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.iconName == rhs.iconName &&
        lhs.colour == rhs.colour &&
        lhs.startDate == rhs.startDate &&
        lhs.goalDate == rhs.goalDate &&
        lhs.complete == rhs.complete &&
        lhs.tags == rhs.tags &&
        lhs.notificationTimes == rhs.notificationTimes &&
        lhs.notificationIDs == rhs.notificationIDs &&
        lhs.repeatTrigger == rhs.repeatTrigger &&
        lhs.repeatRule == rhs.repeatRule
    }
    
    init(
        name: String,
        iconName: String,
        colour: RGBColor,
        startDate: Date,
        goalDate: Date,
        complete: Bool,
        tags: [String] = [],
        notificationTimes: [TimeInterval] = [],
        notificationIDs: [UUID] = [],
        repeatTrigger: RepeatTrigger = .none,
        repeatRule: RepeatRule? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colour = colour
        self.startDate = startDate
        self.goalDate = goalDate
        self.complete = complete
        self.tags = tags
        self.notificationTimes = notificationTimes
        self.notificationIDs = notificationIDs
        self.repeatRule = repeatRule
        self.repeatTrigger = repeatTrigger
    }
    
    func nextDueDate(from reference: Date) -> Date? {
        guard let rule = repeatRule else { return nil }
        return Calendar.current.date(byAdding: rule.unit.calendarComponent, value: rule.value, to: reference)
    }
}
