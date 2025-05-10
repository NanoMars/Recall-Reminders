//
//  ContentView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 7/5/2025.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var viewManager: ViewManager
    @EnvironmentObject var reminderManager: ReminderManager
    @State private var isPresentingCreationForm = false
    
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
                ScrollView {
                    VStack {
                        ForEach(viewList) { view in
                            NavigationLink(destination: RemindersView(
                                title: view.name, sortBy: view.sortBy, sortAscending: view.sortAscending, filters: view.filters
                            )) {
                                Text(view.name)
                            }
                        }
                    }
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
