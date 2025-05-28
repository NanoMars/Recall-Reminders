//
//  SettingsView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 26/5/2025.
//

import SwiftUI
import Toasts

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings: SettingsManager
    @Environment(\.presentToast) var presentToast
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var reminderManager: ReminderManager
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Theme", selection: $settings.theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue.capitalized).tag(theme)
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Button("Delete all data") {
                        let toast = ToastValue(
                            icon: Image(systemName: "trash.fill"),
                            message: "Are you sure?",
                            button: ToastButton(title: "Confirm", color: .red, action: {
                                if let appDomain = Bundle.main.bundleIdentifier {
                                    UserDefaults.standard.removePersistentDomain(forName: appDomain)
                                }
                                viewManager.resetToDefaults()
                                reminderManager.resetToDefaults()
                                settings.resetToDefaults()
                                
                                let toast = ToastValue(
                                    icon: Image(systemName: "checkmark.circle"),
                                    message: "Data successfully deleted."
                                )
                                presentToast(toast)
                            })
                        )

                        presentToast(toast)
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView(settings: SettingsManager.shared)
        .installToast(position: .bottom)
}
