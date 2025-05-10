//
//  CircularProgressBar.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 4/5/2025.
//
import SwiftUI

 

struct CircularProgressBar: View {
    @StateObject var manager: ReminderManager
    @Environment(\.colorScheme) var colorScheme
    @State private var currentDate = Date()
    @State private var isPresentingReminderForm = false
    
    var id: UUID
    var originalDate: Date
    var goalDate: Date
    var selectedIconName: String
    var colour: Color
    @State private var complete: Bool = false
    var preview: Bool = false

    
    
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
            .onTapGesture(perform: {
                if completionProgress < 0.2 && !preview {
                    isPresentingReminderForm = true
                }
            })
            .sheet(isPresented: $isPresentingReminderForm, content: {
                ReminderFormView(editMode: true, id: id)
                    .environmentObject(manager)
            })
            .onChange(of: completionProgress, {
                if completionProgress >= 1 && !preview{
                    manager.markComplete(id: id)
                    complete = true
                }
            })
            .onReceive(manager.$reminders) { reminders in
                if let updatedReminder = reminders.first(where: { $0.id == id }) {
                    complete = updatedReminder.complete
                }
                
            }
        }
        .onAppear {
            if let updatedReminder = manager.reminders.first(where: { $0.id == id}) {
                complete = updatedReminder.complete
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
    ZStack{
        CircularProgressBar(
            manager: ReminderManager(),
            id: UUID(),
            originalDate: Date().addingTimeInterval(0),
            goalDate: Date().addingTimeInterval(30),
            selectedIconName: "tshirt.fill",
            colour: Color.blue,
            preview: true
        )
    }
    .frame(width: 200, height: 200, alignment: .center)
}
