//
//  ContentView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 7/5/2025.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var manager: ViewManager
    @State private var isPresentingCreationForm = false
    
    var body: some View {
        let viewList: [FilteredView] = manager.views
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
                        .environmentObject(manager)
                })
                ScrollView {
                    VStack {
                        ForEach(viewList) { view in
                            NavigationLink(destination: RemindersView(
                                title: view.name, sortBy: view.sortBy, sortAscending: view.sortAscending, filters: view.filters
                            )) {
                                Text(view.name)
                            }
                            .environmentObject(ReminderManager())
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
