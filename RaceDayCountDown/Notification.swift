//
//  Notification.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2020-03-18.
//  Copyright © 2020 charland. All rights reserved.
//

import Foundation
import UserNotifications

struct Notification {

    private static let timedNotificationIdentifier = "timedNotificationIdentifier"

    let content: UNMutableNotificationContent
    let daysBefore: Int
    let interval: TimeInterval

    init(raceName: String, raceDay: Date, daysBefore: Int) {

        let daysBeforeDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: raceDay)
        self.interval = daysBeforeDate?.timeIntervalSinceNow ?? 0
        let name = Self.timedNotificationIdentifier + raceName + String(daysBefore)
        self.daysBefore = daysBefore

        self.content = UNMutableNotificationContent()
        content.title = name
        content.body = "Are you ready?"
        content.body += "Only \(daysBefore) days left to the race!"
    }
}
