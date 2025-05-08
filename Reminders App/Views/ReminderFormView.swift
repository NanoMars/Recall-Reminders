//
//  ReminderFormView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 5/5/2025.
//

import SwiftUI
import SymbolPicker


struct ReminderFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: ReminderManager
    @State private var name = ""
    @State private var iconName = "star.fill"
    @State private var colour = Color.black
    var startDate = Date()
    @State private var goalDate = Date()
    @State private var iconPickerPresented = false

    
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    HStack{
                        Spacer()
                        CircularProgressBar(
                            id: UUID(),
                            
                            originalDate: Date().addingTimeInterval(-120),
                            goalDate: Date().addingTimeInterval(120),
                            selectedIconName: iconName,
                            colour: colour,
                            complete: false)
                                
                            .frame(width: 200, height: 200)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                TextField("Name", text: $name)
                
                DatePicker(
                    "End Date",
                    selection: $goalDate,
                    in: Date().addingTimeInterval(60)...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                HStack{
                    Text("icon")
                        .foregroundStyle(.black)
                    Spacer()
                    Button(action: {
                        iconPickerPresented = true
                    }) {
                        ZStack {
                            /*RoundedRectangle(cornerRadius: 8)
                                .frame(width: 40.0, height: 40.0)
                                .foregroundColor(Color(.systemBackground))*/
                            Image(systemName: iconName)
                                .foregroundStyle(iconPickerPresented ? .blue : .black)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .sheet(isPresented: $iconPickerPresented) {SymbolPicker(symbol: $iconName)}
                
                ColorPicker("Color", selection: $colour)
                
                Section {
                    Button("Create reminder") {
                        print("button clicked")
                        if (
                            name != "" &&
                            iconName != "" &&
                            goalDate > Date()
                        ) {
                            print("Create reminder")
                            let creationDate = Date()
                            manager.addReminder(reminder: Reminder(
                                    name: name,
                                    iconName: iconName,
                                    colour: convertToRGBColor(color: colour),
                                    startDate: creationDate,
                                    goalDate: goalDate,
                                    complete: false
                                )
                            )
                            dismiss()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.black)
                }
                .listRowBackground(Color.clear)

            }
            .navigationTitle("Create a reminder")
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

func convertToRGBColor(color: Color) -> RGBColor {
    let uiColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return RGBColor(
        r: Double(red * 255),
        g: Double(green * 255),
        b: Double(blue * 255)
    )
}

#Preview {
    ReminderFormView()
        .environmentObject(ReminderManager())
}
