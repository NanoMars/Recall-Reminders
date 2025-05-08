//
//  ReminderListFormView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 7/5/2025.
//


//
//  ReminderListFormView
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 7/5/2025.
//

import SwiftUI


struct ReminderListFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: ViewManager
    @State private var selectedSort: String = "goalDate"
    @State private var sortAscending: Bool = false
    @State private var showCompleted: Bool = true
    @State private var name: String = ""
    var body: some View {
        NavigationStack{
            Form {
                Section(header: Text("Title")){
                    TextField("|", text: $name)
                }
                Section(header: Text("Sorting")) {
                    Picker("Sort by", selection: $selectedSort) {
                        Text("Due Date").tag("goalDate")
                        Text("Creation Date").tag("startDate")
                    }
                    .pickerStyle(MenuPickerStyle())
                    Picker("Sort", selection: $sortAscending) {
                        Text("Decending").tag(false)
                        Text("Ascending").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("Filters")) {
                    Toggle("Show Completed", isOn: $showCompleted)
                }
                Section {
                    Button("Create View") {
                        if name != "" {
                            manager.addView(view: FilteredView(
                                name: name,
                                sortBy: selectedSort,
                                sortAscending: sortAscending,
                                filters: showCompleted ? [] : ["completed"]
                            ))
                            dismiss()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.black)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Create a view")
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction, content: {
                    Button("Close") {
                        dismiss()
                    }
                })
            })
        }
        
    }
}



#Preview {
    ReminderListFormView()
        .environmentObject(ViewManager())
}
