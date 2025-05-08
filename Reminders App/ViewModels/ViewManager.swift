//
//  ViewManager.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 7/5/2025.
//

import Foundation
import SwiftUI

class ViewManager: ObservableObject {
    @Published var views: [FilteredView] = []
    @Environment(\.colorScheme) var colorScheme
    
    let saveKey = "views"
    
    init() {
        loadViews()
        addView(view: FilteredView(
            name: "coolname",
            sortBy: "something",
            sortAscending: false,
            filters: ["something else"]
            
        ))
    }
    
    func addView(view: FilteredView) {
        views.append(view)
        saveViews()
    }
    
    func removeView(id: UUID) {
        views.removeAll { $0.id == id}
        saveViews()
    }
    
    private func saveViews() {
        if let encoded = try? JSONEncoder().encode(views) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadViews() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([FilteredView].self, from: data) {
            views = decoded
        }
    }
}


