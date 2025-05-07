//
//  FilteredView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 7/5/2025.
//

import Foundation

struct FilteredView: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sortBy: String
    var filters: [String]
}

