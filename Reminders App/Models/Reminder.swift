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


final class Reminder: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var iconName: String
    @Published var colour: RGBColor
    @Published var startDate: Date
    @Published var goalDate: Date
    @Published var complete: Bool
    
    init(name: String, iconName: String, colour: RGBColor, startDate: Date, goalDate: Date, complete: Bool) {
        self.name = name
        self.iconName = iconName
        self.colour = colour
        self.startDate = startDate
        self.goalDate = goalDate
        self.complete = complete
    }
}
