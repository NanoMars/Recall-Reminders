//
//  ReminderFormView.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 5/5/2025.
//

import SwiftUI
import SymbolPicker
import Toasts

extension RepeatTrigger {
    var displayName: String {
        switch self {
        case .none: return "Don't repeat"
        case .atDueDate: return "Repeat at due date"
        case .afterCompletion: return "Reapeat after completion"
        }
    }
}

struct ReminderFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: ReminderManager
    @Environment(\.presentToast) var presentToast
    @State private var name = ""
    @State private var iconName = "star.fill"
    @State private var colour = Color.black
    @State private var startDate = Date()
    @State private var goalDate = Date()
    @State private var iconPickerPresented = false
    @State private var tags: [String] = []
    @State private var notificationTimes: [TimeInterval] = [0]
    @State private var selectedNotificationTimeStrings: [String] = ["0"]
    @State private var repeatTrigger: RepeatTrigger = .none
    @State private var repeatValueString: String = "1"
    @State private var repeatUnit: RepeatUnit = .day
    
   
    
    
    
    
    
    @State private var minimumGoalDate = Date()
    
    @State private var multiPickerOverlayHeight: CGFloat = 0
    
    @State private var textFieldY: CGFloat = 0
    
    @State private var multiPickerText = ""
    @FocusState private var multiPickerIsFocused: Bool
    
    var editMode = false
    var id = UUID()
    
    private var filteredTags: [String] {
        guard !multiPickerText.isEmpty else { return [] }
        return Array(multiPickerOptions.filter {
            $0.lowercased().contains(multiPickerText.lowercased()) && !tags.contains($0)  }.prefix(3))
    }
    
    var multiPickerOptions: [String] {
        let counts = manager.tagCounts
        var returning: [String] = []
        for count in counts {
            returning.append(count.key)
        }
        return returning
    }
    
    private var progressSection: some View {
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
    }
    
    private var repeatSection: some View {

        Section("Repeat") {
            Picker("", selection: $repeatTrigger) {
                ForEach(RepeatTrigger.allCases) { trig in
                    Text(trig.displayName)
                        .tag(trig)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if repeatTrigger != .none {
                HStack {
                    Text("Every")
                    TextField("1", text: $repeatValueString)
                        .keyboardType(.numberPad)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 0.0)
                    Picker("", selection: $repeatUnit) {
                        ForEach(RepeatUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue)
                                .tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
    
    private var basicFieldSection: some View {
        Section {
            TextField("Name", text: $name)
            
            DatePicker(
                "End Date",
                selection: $goalDate,
                in: minimumGoalDate...,
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
        }
        
    }
    
    private func NotificationRow(index: Int) -> some View {
        let binding = Binding(
            get: {
                selectedNotificationTimeStrings[index]
            },
            set: { newValue in
                selectedNotificationTimeStrings[index] = newValue
                if let minutes = Int(newValue) {
                    notificationTimes[index] = TimeInterval(minutes)
                }
            }
        )
        
        return HStack {
            Text("Notify")
            TextField("", text: binding)
                .keyboardType(.numberPad)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 0.0)
            Text("minutes before")
        }
        .swipeActions(content: {
            Button("Delete") {
                selectedNotificationTimeStrings.remove(at: index)
            }
        })
    }
    
    private var notificationSection: some View {
        Group {
            Section {
                ForEach(0..<selectedNotificationTimeStrings.count, id: \.self) { index in
                    NotificationRow(index: index)
                }
            }
            Section {
                HStack {
                    Button("Add new notification") {
                        if selectedNotificationTimeStrings.count < 3 {
                            selectedNotificationTimeStrings.append("10")
                            notificationTimes.append(10)
                        }
                    }
                }
            }
        }
    }
    
    private var footerSection: some View {
        Section {
            HStack(alignment: .center) {
                Button(editMode ? "Apply Edit" : "Create reminder") {
                    print("button clicked")
                    if name.isEmpty {
                            let toast = ToastValue(
                                icon: Image(systemName: "exclamationmark.triangle"),
                                message: "Name cannot be empty."
                            )
                            presentToast(toast)
                    } else if iconName.isEmpty {
                        let toast = ToastValue(
                            icon: Image(systemName: "exclamationmark.triangle"),
                            message: "Please choose an icon."
                        )
                        presentToast(toast)
                    }else if goalDate <= Date() {
                        let toast = ToastValue(
                            icon: Image(systemName: "exclamationmark.triangle"),
                            message: "Date cannot be in the past."
                        )
                        presentToast(toast)
                    }else if repeatTrigger != .none && !(Int(repeatValueString) ?? 0 >= (repeatUnit == .minute ? 5 : 1)) {
                        let toast = ToastValue(
                            icon: Image(systemName: "exclamationmark.triangle"),
                            message: "Repeat interval must be at least 5 minutes."
                        )
                        presentToast(toast)
                    }else {

                        manager.hasNotificationPermission { granted in
                            let repeatValue = Int(repeatValueString) ?? 0
                            let validRepeat = repeatValue >= (repeatUnit == .minute ? 5 : 1)
                            let resolvedRepeatRule: RepeatRule? = validRepeat ? RepeatRule(value: repeatValue, unit: repeatUnit) : nil
                            let resolvedRepeatTrigger: RepeatTrigger = validRepeat ? repeatTrigger : .none
                            if granted {
                                DispatchQueue.main.async {
                                    print("Create reminder")
                                    let creationDate = Date()
                                    
                                    let newReminder = Reminder(
                                        name: name,
                                        iconName: iconName,
                                        colour: convertToRGBColor(color: colour),
                                        startDate: creationDate,
                                        goalDate: goalDate,
                                        complete: false,
                                        tags: tags,
                                        repeatTrigger: resolvedRepeatTrigger,
                                        repeatRule: resolvedRepeatRule
                                    )
                                    
                                    let timesInSeconds = notificationTimes.map {$0 * 60}
                                    newReminder.notificationTimes = timesInSeconds
                                    if !editMode {
                                        manager.addReminder(reminder: newReminder)
                                    } else {
                                        
                                        manager.editReminder(id: id, newReminder: newReminder)
                                    }
                                    dismiss()
                                }
                            } else {
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, settings in
                                    if granted {
                                        let toast = ToastValue(
                                            icon: Image(systemName: "checkmark.circle"),
                                            message: "Permissions successfully granted."
                                        )
                                    
                                        presentToast(toast)
                                    } else {
                                        let toast = ToastValue(
                                            icon: Image(systemName: "exclamationmark.triangle"),
                                            message: "Permissions not granted.",
                                            button: ToastButton(title: "Fix", color: .red, action: {
                                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                                    if UIApplication.shared.canOpenURL(appSettings) {
                                                        UIApplication.shared.open(appSettings)
                                                    }
                                                }
                                            })
                                        )
                                    
                                        presentToast(toast)
                                    }
                                }
                            }
                        }
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
    }
    
    private var multiPickerSection: some View {
        Section {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .swipeActions(content: {
                        Button("Delete") {
                            if let index = tags.firstIndex(of: tag) {
                                tags.remove(at: index)
                            }
                        }
                    })
            }

            
            TextField("Add a tag", text: $multiPickerText)
                .focused($multiPickerIsFocused)
                .submitLabel(.return)
                .onSubmit {
                    if !tags.contains(multiPickerText) {tags.append(multiPickerText)}
                    multiPickerText = ""
                }
                .background(
                    GeometryReader {geo in
                        Color.clear
                            .onAppear {
                                textFieldY = geo.frame(in: .global).minY
                            }
                            .onChange(of: multiPickerText) {
                                textFieldY = geo.frame(in: .global).minY
                            }
                    }
                )

        }
        //.listRowBackground(Color.clear)
    }
    
    private var multiPickerOverlaySection: some View {
        
        GeometryReader { geo in
            Group {
                if multiPickerIsFocused && !filteredTags.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(filteredTags, id: \.self) { suggestion in
                                Text(suggestion)
                                    .onTapGesture {
                                        if !tags.contains(suggestion) {tags.append(suggestion)}
                                        multiPickerText = ""
                                    }
                                    .padding()
                                Divider()
                            }
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    multiPickerOverlayHeight = proxy.size.height
                                }
                                .onChange(of: filteredTags) {
                                    multiPickerOverlayHeight = proxy.size.height
                                }
                            
                        })
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 300, maxHeight: 150)
                    
                    .position(x: geo.size.width / 2, y: textFieldY + (multiPickerOverlayHeight / 2) - 100)
                    
                }
            }
            
        }
        .listRowBackground(Color.clear)
    }
    
    var body: some View {
        
        
        NavigationStack {
            ZStack {
                Form {
                    progressSection
                    basicFieldSection
                    repeatSection
                    multiPickerSection
                    notificationSection
                    footerSection
                }
                .coordinateSpace(name: "formScroll")
                multiPickerOverlaySection

            }
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
            minimumGoalDate = Date().addingTimeInterval(60)
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
                tags = tempReminder?.tags ?? []
                print("notificationIDs = \(String(describing: tempReminder?.notificationIDs))")
                notificationTimes = []
                selectedNotificationTimeStrings = []
                repeatTrigger = tempReminder?.repeatTrigger ?? .none
                repeatUnit = tempReminder?.repeatRule?.unit ?? .day
                repeatValueString = String(tempReminder?.repeatRule?.value ?? 1)
                
                let times = tempReminder?.notificationTimes ?? [0]
                notificationTimes = times.map {$0 / 60}
                selectedNotificationTimeStrings = times.map {String(Int($0 / 60))}
            }
        }
    }
}

func returnReminder(id: UUID, manager: ReminderManager) -> Reminder? {
    return manager.reminders.first(where: { $0.id == id })
}

func getNotificationTime(endDate: Date, id: UUID, completion: @escaping (TimeInterval?) -> Void) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        guard
            let request = requests.first(where: {$0.identifier == id.uuidString}),
            let callTrigger = request.trigger as? UNCalendarNotificationTrigger,
            let fireDate = Calendar.current.date(from: callTrigger.dateComponents)
        else {
            completion(nil)
            return
        }
         
        let interval = endDate.timeIntervalSince(fireDate)
        completion(interval)
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
    ReminderFormView(editMode: false)
        .environmentObject(ReminderManager())
}
