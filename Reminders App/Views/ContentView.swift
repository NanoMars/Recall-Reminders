//
//  ContentView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 7/5/2025.
//

import SwiftUI

extension UUID: Identifiable {
    public var id: UUID {self}
}

struct ContentView: View {
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var isPresentingCreationForm = false
    //@State private var isPresentingEditingForm = false
    @State private var selectedViewID: UUID?
    
    var body: some View {
        let viewList: [FilteredView] = viewManager.views
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Button("+") {
                        isPresentingCreationForm = true
                    }
                    .padding(.trailing)
                    
                }
                .sheet(isPresented: $isPresentingCreationForm, content: {
                    ReminderListFormView()
                        .environmentObject(viewManager)
                        .environmentObject(reminderManager)
                })
                Form {
                    ForEach(viewList) { view in
                        NavigationLink(destination: RemindersView(
                            title: view.name, sortBy: view.sortBy, sortAscending: view.sortAscending, filters: view.filters, filtersExclusive: view.filtersExclusive
                        )) {
                            Text(view.name)
                        }
                        .swipeActions(content: {
                            Button("Delete") {
                                viewManager.removeView(id: view.id)
                            }
                            .tint(.red)
                            Button("Edit") {
                                selectedViewID = view.id
                                /*DispatchQueue.main.async {
                                    isPresentingEditingForm = true
                                }*/
                            }
                            .tint(.blue)
                        })
                    }
                }
                .frame(maxWidth: .infinity)
                .sheet(item: $selectedViewID) { id in
                    ReminderListFormView(editMode: true, id: id)
                        .environmentObject( viewManager)
                }
            }
        }
    }
    
    
}
#Preview {
    ContentView()
        .environmentObject(ViewManager())
        .environmentObject(ReminderManager())
}
