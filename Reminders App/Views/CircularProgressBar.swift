//
//  CircularProgressBar.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//
import SwiftUI

 

struct CircularProgressBar: View {
    @StateObject var manager =  ReminderManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var currentDate = Date()
    
    var id: UUID
    var originalDate: Date
    var goalDate: Date
    var selectedIconName: String
    var colour: Color
    @State private var complete: Bool
    
    init(
     id: UUID,
     originalDate: Date,
     goalDate: Date,
     selectedIconName: String,
     colour: Color,
     complete initialComplete: Bool
    ) {
        self.id = id
        self.originalDate = Date()
        self.goalDate = goalDate
        self.selectedIconName = selectedIconName
        self.colour = colour
        _complete = State(initialValue: initialComplete)
    }
    
    var progress: Double {
        calculateDateProgress(currentDate: currentDate, goalDate: goalDate, originalDate: originalDate)
    }
    
    @State private var isPressed = false
    
    @State private var completionProgress: Double = 0
    
    
    var body: some View {
        
        GeometryReader { geometry in
            var thickness: CGFloat {min(geometry.size.width, geometry.size.height)  * 0.1 }
            ZStack {
                ZStack{
                    Circle()
                        .foregroundStyle(colour)
                        .mask(
                            GeometryReader { geo in
                                Rectangle()
                                    .frame(
                                        width: geo.size.width,
                                        height: geo.size.height,
                                        alignment: .bottom
                                        )
                                    .position(x: geo.size.width / 2, y: geo.size.height * (1.5 - (complete ? 1 : completionProgress)))
                            }
                        )
                    // slice this based on holdprogress
                    // this circle is the background I want sliced vertically
                }
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(colour, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                    .frame(width: geometry.size.width - thickness, height: geometry.size.height)
                    
                    .foregroundColor(colour)
                Image(systemName: selectedIconName)
                    .resizable(resizingMode: .stretch)
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fit/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .padding(.all, thickness + 20)
                
            }
            //.padding(.all, 20.0)
            .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
            ) { time in
                currentDate = time
                
                if isPressed {
                    completionProgress = min(1, max(0, completionProgress + 0.01))
                    print("hi")
                } else {
                    completionProgress = min(1, max(0, completionProgress - 0.01))
                }
            }
            .simultaneousGesture (
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        isPressed = true
                    })
                    .onEnded({ _ in
                        isPressed = false
                    })
            )
            .onChange(of: completionProgress, {
                if completionProgress >= 1 {
                    manager.markComplete(id: id)
                    complete = true
                }
            })
        }
    }
}

func calculateDateProgress(currentDate: Date, goalDate: Date, originalDate: Date) -> Double {
    let totalTime = goalDate.timeIntervalSince(originalDate)
    let elapsed = currentDate.timeIntervalSince(originalDate)
    return min(max(elapsed / totalTime, 0), 1) // clamp between 0 and 1
}

#Preview {
    ZStack{
        CircularProgressBar(
            id: UUID(),
            originalDate: Date().addingTimeInterval(0),
            goalDate: Date().addingTimeInterval(0),
            selectedIconName: "tshirt.fill",
            colour: Color.blue,
            complete: true
        )
    }
    .frame(width: 200, height: 200, alignment: .center)
}
