//
//  Reminder.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import Foundation

struct RGBColor: Codable {
    var r: Double
    var g: Double
    var b: Double
}

struct Reminder: Identifiable, Codable {
    var id = UUID()
    var name: String
    var iconName: String
    var colour: RGBColor
    var startDate: Date
    var goalDate: Date
    var complete: Bool
}
