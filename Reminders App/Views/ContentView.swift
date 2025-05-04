//
//  ContentView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var manager =  ReminderManager()
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(manager.reminders) { reminder in
                    CircularProgressBar(
                        originalDate: reminder.startDate,
                        goalDate: reminder.goalDate,
                        selectedIconName: reminder.iconName,
                        colour: convertToColor(rgb: reminder.colour)
                        )
                }
            }
        }
        .padding(.all, 15.0)
        
    }
}

func convertToColor(rgb: RGBColor) -> Color {
    return Color(
        red: rgb.r / 255.0,
        green: rgb.g / 255.0,
        blue: rgb.b / 255.0
    )
}

#Preview {
    ContentView()
}
