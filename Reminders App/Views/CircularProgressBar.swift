//
//  CircularProgressBar.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//
import SwiftUI

var thickness: CGFloat = 20

struct CircularProgressBar: View {
    var originalDate: Date
    var goalDate: Date
    var selectedIconName: String
    var colour: Color
    
    var progress: Double {
        calculateDateProgress(date: goalDate, originalDate: originalDate)
    }
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                .foregroundColor(colour)
            Image(systemName: selectedIconName)
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fit/*@END_MENU_TOKEN@*/)
                .padding(.all, thickness + 20)
        }
        .padding(.all, 20.0)
    }
}

func calculateDateProgress(date: Date, originalDate: Date) -> Double {
    let currentDate = Date()
    let totalTime = date.timeIntervalSince(originalDate)
    let elapsed = currentDate.timeIntervalSince(originalDate)
    let progress = elapsed / totalTime
    return min(max(progress, 0), 1) // clamp between 0 and 1
}

#Preview {
    CircularProgressBar(
        originalDate: Date().addingTimeInterval(-3600),
        goalDate: Date().addingTimeInterval(3600),
        selectedIconName: "tshirt.fill",
        colour: .blue
    )
}
