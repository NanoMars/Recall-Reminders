//
//  ReminderFormView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 5/5/2025.
//

import SwiftUI

struct ReminderFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var iconName = "star.fill"
    @State private var colour = Color.black
    var startDate = Date()
    @State private var goalDate = Date()
    
    var body: some View {
        VStack() {
            HStack() {
                Text("Create a new reminder")
                    .font(.system(size: 24, weight: .bold, design: .default))
                Spacer()
                Button(action: {
                    
                }) {
                    ZStack() {
                        Circle()
                            .fill(.white)
                            .shadow(radius: 5)
                        Image(systemName: "xmark")
                            .resizable(resizingMode: .stretch)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15.0, height: 15.0)
                            .foregroundStyle(.black)
                    }
                }
                .frame(height: 24.0)
            }
            
            Color(.clear)
                .frame(height: 16.0)
            
            
            
            CircularProgressBar(originalDate: Date().addingTimeInterval(-120), goalDate: Date().addingTimeInterval(120), selectedIconName: iconName, colour: colour)
                .frame(width: 200, height: 200)
                
            
            Color(.clear)
                .frame(height: 8.0)
                
            HStack() {
                Text("Name")
                    .font(.system(size: 20, weight: .bold, design: .default))
                Spacer()
            }
            
            TextField("Type", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            
            Color(.clear)
                .frame(height: 8.0)
            
            HStack() {
                Text("Icon")
                    .font(.system(size: 20, weight: .bold, design: .default))
                Spacer()
            }
            
            TextField("Type", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            
            Color(.clear)
                .frame(height: 8.0)
            
            HStack() {
                Text("Colour")
                    .font(.system(size: 20, weight: .bold, design: .default))
                Spacer()
            }
            
            TextField("Type", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            
            Color(.clear)
                .frame(height: 8.0)
            
            HStack() {
                Text("Date / Time")
                    .font(.system(size: 20, weight: .bold, design: .default))
                Spacer()
            }
            
            TextField("Type", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            
            Color(.clear)
                .frame(height: 8.0)
            
            Button(action: {
                
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius:15)
                        .foregroundStyle(.orange)
                    Text("Create")
                        .foregroundStyle(.white)
                    
                }
                .frame(width: 160, height: 60)
            }
            Spacer()
        }
        .padding(.horizontal)
        
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
}
