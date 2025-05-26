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
import Toasts


struct ReminderListFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var reminderManager: ReminderManager
    @Environment(\.presentToast) var presentToast
    @State private var selectedSort: String = "goalDate"
    @State private var sortAscending: Bool = false
    @State private var showCompleted: Bool = true
    @State private var name: String = ""
    @State var filters: [String] = []
    
    @State private var tagPickerPresented: Bool = false
    @State private var filtersExclusive: Bool = true
    
    var multiPickerOptions: [String] {
        let counts = reminderManager.tagCounts
        var returning: [String] = []
        for count in counts {
            returning.append(count.key)
        }
        return returning
    }
    
    var editMode = false
    var id = UUID()
    
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
                    
                    Button("Pick tags") {
                        tagPickerPresented = true
                    }
                    .sheet(isPresented: $tagPickerPresented, content: {
                        MultiPickerScreen( pickedTags: $filters, editMode: false)
                            .environmentObject(reminderManager)
                    })
                    
                    Picker("Exclusive or Inclusive ", selection: $filtersExclusive) {
                        Text("Exclusive").tag(true)
                        Text("Inclusive").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Button(editMode ? "Apply Edits" : "Create View") {
                        if name.isEmpty {
                            let toast = ToastValue(
                                icon: Image(systemName: "exclamationmark.triangle"),
                                message: "Name cannot be empty."
                            )
                            presentToast(toast)
                        } else {
                            let newView = FilteredView (
                                name: name,
                                sortBy: selectedSort,
                                sortAscending: sortAscending,
                                filtersExclusive: filtersExclusive,
                                filters: filters,
                                show_completed: showCompleted
                            )
                            print(filtersExclusive, sortAscending)
                            if editMode {
                                viewManager.editView(id: id, newView: newView)
                            } else {
                                viewManager.addView(view: newView)
                            }
                            dismiss()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.black)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle(editMode ? "Edit View" : "Create a View")
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction, content: {
                    Button("Close") {
                        dismiss()
                    }
                })
            })
        }
        .onAppear {
            if editMode {
                let tempView = returnView(id: id, manager: viewManager)
                selectedSort = tempView?.sortBy ?? "goalDate"
                sortAscending = tempView?.sortAscending ?? false
                showCompleted = tempView?.filters.contains("completed") ?? true
                name = tempView?.name ?? "Unknown"
                filtersExclusive = tempView?.filtersExclusive ?? false
                filters = tempView?.filters ?? []
            }
        }
    }
}

func returnView(id: UUID, manager: ViewManager) -> FilteredView? {
    return manager.views.first(where: { $0.id == id })
}

#Preview {
    ReminderListFormView(editMode: false)
        .environmentObject(ViewManager())
}
