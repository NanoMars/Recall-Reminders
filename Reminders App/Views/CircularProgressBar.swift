//
//  CircularProgressBar.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//
import SwiftUI

 

struct CircularProgressBar: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var currentDate = Date()
    
    var originalDate: Date
    var goalDate: Date
    var selectedIconName: String
    var colour: Color
    
    var progress: Double {
        calculateDateProgress(currentDate: currentDate, goalDate: goalDate, originalDate: originalDate)
    }
    var body: some View {
        GeometryReader { geometry in
            var thickness: CGFloat {min(geometry.size.width, geometry.size.height)  * 0.1 }
            ZStack {
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(colour, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                    .frame(width: geometry.size.width - thickness, height: geometry.size.height - thickness)
                    
                    .foregroundColor(colour)
                Image(systemName: selectedIconName)
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fit/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding(.all, thickness + 20)
            }
            .padding(.all, 20.0)
            .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            ) { time in
                currentDate = time
            }
        }
    }
}

func calculateDateProgress(currentDate: Date, goalDate: Date, originalDate: Date) -> Double {
    let totalTime = goalDate.timeIntervalSince(originalDate)
    let elapsed = currentDate.timeIntervalSince(originalDate)
    return min(max(elapsed / totalTime, 0), 1) // clamp between 0 and 1
}

#Preview {
    CircularProgressBar(
        originalDate: Date().addingTimeInterval(-3600),
        goalDate: Date().addingTimeInterval(3600),
        selectedIconName: "tshirt.fill",
        colour: Color.blue
    )
    .frame(width: 200, height: 200, alignment: .center)
}
