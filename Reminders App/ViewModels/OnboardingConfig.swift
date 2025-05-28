//
//  OnboardingConfig.swift
//  Reminders App
//
//  Created by Armand Packham-McGuiness on 28/5/2025.
//

import OnboardingKit
import SwiftUI

extension OnboardingConfiguration {
    static let prod = Self.init(privacyUrlString: "",
                                accentColor: .blue,
                                features: [
                                    .init(image: Image(systemName: "checkmark.circle"), title: "Stay Organised", content: "Stay on top of your tasks with reminders that show progress before they're due."),
                                    .init(image: Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled"), title: "Keep things seperate", content: "Seperate reminders into different views with tags."),
                                    .init(image: Image(systemName: "bell.badge"), title: "Notifications", content: "Never miss a beat with up to 3 notifications per reminder.")
                                ])
}
