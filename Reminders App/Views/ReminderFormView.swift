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
    @State private var startDate = Date()
    @State private var goalDate = Date()
    @State private var iconPickerPresented = false
    var editMode = false
    var id = UUID()

    
    var body: some View {
        
        
        NavigationStack {
            
            Form(content: {
                Section {
                    HStack{
                        Spacer()
                        CircularProgressBar(
                            manager: manager,
                            id: UUID(),
                            
                            originalDate: Date().addingTimeInterval(-120),
                            goalDate: Date().addingTimeInterval(120),
                            selectedIconName: iconName,
                            colour: colour,
                            preview: true
                        )
                                
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
                    HStack {
                        Button(editMode ? "Apply Edit" : "Create reminder") {
                            print("button clicked")
                            if (
                                name != "" &&
                                iconName != "" &&
                                goalDate > Date()
                            ) {
                                print("Create reminder")
                                let creationDate = Date()
                                
                                let newReminder = Reminder(
                                    name: name,
                                    iconName: iconName,
                                    colour: convertToRGBColor(color: colour),
                                    startDate: creationDate,
                                    goalDate: goalDate,
                                    complete: false
                                )
                                
                                if !editMode {
                                    manager.addReminder(reminder: newReminder)
                                } else {
                                    manager.editReminder(id: id, newReminder: newReminder)
                                }
                                dismiss()
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(.black)
                        
                        if editMode {
                            Button("Delete Reminder") {
                                manager.removeReminder(id: id)
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                            .foregroundStyle(.red)
                        }
                    }
                }
                .listRowBackground(Color.clear)

            })
            .navigationTitle(editMode ? "Edit Reminder" : "Create a reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("Close") {
                        dismiss()
                    }
                })
            }
        }
        
        .onAppear {
            if editMode {
                let tempReminder = returnReminder(id: id, manager: manager)
                name = tempReminder?.name ?? "Unknown"
                iconName = tempReminder?.iconName ?? "questionmark.diamond"
                if let tempColour = tempReminder?.colour {
                    colour = Color(
                        red: tempColour.r / 255,
                        green: tempColour.g / 255,
                        blue: tempColour.b / 255
                    )
                } else {
                    colour = .blue
                }
                startDate = tempReminder?.startDate ?? Date().addingTimeInterval(-3600)
                goalDate = tempReminder?.goalDate ?? Date().addingTimeInterval(3600)
                
            }
        }
    }
}

func returnReminder(id: UUID, manager: ReminderManager) -> Reminder? {
    return manager.reminders.first(where: { $0.id == id })
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
    ReminderFormView(editMode: true)
        .environmentObject(ReminderManager())
}
