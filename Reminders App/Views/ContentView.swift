//
//  ContentView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var manager =  ReminderManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var isPresentingReminderForm = false
    
    var bottomArea: CGFloat = 80
    var reminderPadding: CGFloat = 15
    
    var bottomSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.bottom ?? 0
    }
    
    var topSafeArea: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                // add a spacer here at topsafearea size
                Color.clear
                    .frame(height: topSafeArea)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(manager.reminders) { reminder in

                                
                        CircularProgressBar(
                            id: reminder.id,
                            originalDate: reminder.startDate,
                            goalDate: reminder.goalDate,
                            selectedIconName: reminder.iconName,
                            colour: convertToColor(rgb: reminder.colour),
                            complete: reminder.complete
                        )
                        .aspectRatio(1, contentMode: .fit)
                    
                    }
                }
                .padding(.horizontal, 16)
            }
            
            
            .padding([.top], reminderPadding)
            .padding(.bottom, bottomArea + bottomSafeArea)
            .ignoresSafeArea(edges: .top)
            
            
            ZStack {
                Rectangle()
                    .fill(colorScheme == .dark ? .black : .white)
                    .frame(height: bottomArea + bottomSafeArea)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .bottom)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                HStack(alignment: .center) {
                    Button(action: {
                        isPresentingReminderForm = true
                    }) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                                .frame(width: 50.0, height: 50.0)
                                .shadow(radius: 5)
                            Image(systemName: "plus")
                                .resizable(resizingMode: .stretch)
                                .frame(width: 30.0, height: 30.0)
                                .foregroundStyle(.white)
                        }

                    }
                    .sheet(isPresented: $isPresentingReminderForm, content: {
                        ReminderFormView()
                            .environmentObject(manager)
                    })
                    
                    
                }
                .padding(.bottom, bottomSafeArea)
            }
        }
        .ignoresSafeArea(edges: .bottom)
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
