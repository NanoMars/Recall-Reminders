//
//  SettingsView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 26/5/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings: SettingsManager
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Theme", selection: $settings.theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue.capitalized).tag(theme)
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button("Close") {
                    dismiss()
                }
            })
        }
    }
}
