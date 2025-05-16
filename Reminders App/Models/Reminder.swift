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
    
    enum CodingKeys: String, CodingKey {
        case id, name, iconName, colour, startDate, goalDate, complete, tags, notificationTimes
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
        try container.encode(tags, forKey: .notificationTimes)
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
        lhs.notificationTimes == rhs.notificationTimes
    }
    
    init(
        name: String,
        iconName: String,
        colour: RGBColor,
        startDate: Date,
        goalDate: Date,
        complete: Bool,
        tags: [String] = [],
        notificationTimes: [TimeInterval] = []
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
    }
}
