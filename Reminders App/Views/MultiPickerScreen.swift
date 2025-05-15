//
//  MultiPickerScreen.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 11/5/2025.
//

import SwiftUI

struct MultiPickerScreen: View {
    @EnvironmentObject var manager: ReminderManager
    @Binding var pickedTags: [String]
    @State var editMode: Bool
    @Environment(\.dismiss) var dismiss
    
    var multiPickerOptions: [String] {
        let counts = manager.tagCounts
        var returning: [String] = []
        for count in counts {
            returning.append(count.key)
        }
        return returning.filter {!pickedTags.contains($0)}
    }
    
    var body: some View {
        NavigationStack{
            Form {
                if !pickedTags.isEmpty {
                    Section("Remove tags") {
                        ForEach(pickedTags, id: \.self) { tag in
                            Button(action: {
                                pickedTags.removeAll { $0 == tag }
                            }) {
                                HStack {
                                    Text(tag)
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                    }
                }
                if !multiPickerOptions.isEmpty {
                    Section("Pick tags") {
                        ForEach(multiPickerOptions, id: \.self) { tag in
                            Button(action: {
                                pickedTags.append(tag)
                            }) {
                                HStack {
                                    Text(tag)
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(editMode ? "Edit Tags" : "Add Tags")
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

#Preview {
    @Previewable @State var samplePickedTags: [String] = []
    MultiPickerScreen(pickedTags: $samplePickedTags, editMode: false)
        .environmentObject(ReminderManager())
}

