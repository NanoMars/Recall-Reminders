//
//  ContentView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 7/5/2025.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var manager: ViewManager
    
    var body: some View {
        let viewList: [FilteredView] = manager.views
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewList) { view in
                        NavigationLink(destination: RemindersView()) {
                            Text(view.name)
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
}
