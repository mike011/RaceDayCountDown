//
//  RaceInfo.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2020-03-18.
//  Copyright © 2020 charland. All rights reserved.
//

import Foundation
import UserNotifications
import os.log

class RaceInfo: NSObject, NSCoding {

    private static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("races")

    private let timerGraphic = "timerGraphic"

    let raceName: String
    let raceDay: Date
    private var notifications: [Notification]

    required convenience init?(coder aDecoder: NSCoder) {
        guard let race = aDecoder.decodeObject(forKey: PropertyKey.race) as? String else {
            os_log("Unable to decode the race for a Race object.", log: OSLog.default, type: .debug)
            return nil
        }
        let day = aDecoder.decodeObject(forKey: PropertyKey.day) as! Date
        self.init(race: race, day: day)
    }

    init(race: String, day: Date) {
        raceName = race
        raceDay = day

        notifications = [Notification]()
        for daysBefore in [3, 10, 25] {
            notifications.append(Notification(raceName: race, raceDay: day, daysBefore: daysBefore))
        }
    }

    // MARK: NSCoding

    func encode(with aCoder: NSCoder) {
        aCoder.encode(raceName, forKey: PropertyKey.race)
        aCoder.encode(raceDay, forKey: PropertyKey.day)
    }

    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.scheduleNotifications(notifications: self.notifications)
            } else {
                // User has not given permissions
                center.requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { granted, error in
                    if let error = error {
                        print(error)
                    } else if granted {
                        self.scheduleNotifications(notifications: self.notifications)
                    }
                })
            }
        }
    }

    func scheduleNotifications(notifications: [Notification]) {
        for notification in notifications {
            scheduleNotification(notification: notification)
        }
    }

    func isPositive(interval: TimeInterval) -> Bool {
        let isZero = interval.isZero
        let isNegative = interval.isLess(than: 0)
        return !isZero && !isNegative
    }

    func scheduleNotification(notification: Notification) {
        if isPositive(interval: notification.interval) {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: notification.interval, repeats: false)
            scheduleNotification(content: notification.content, name: notification.content.title, trigger: trigger)
        }
    }

    func scheduleNotification(content: UNMutableNotificationContent, name: String, trigger: UNNotificationTrigger) {
        let url = Bundle.main.url(forResource: "socks", withExtension: "jpeg")!
        let imageAttachement = try! UNNotificationAttachment(identifier: timerGraphic, url: url, options: nil)
        content.attachments.append(imageAttachement)

        let notificationRequest = UNNotificationRequest(identifier: name, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(notificationRequest) { error in
            if let error = error {
                print(error)
            } else {
                print("Notification scheduled")
            }
        }
    }

    func removeNotifications() {
        for notification in notifications {
            removeNotifications(name: notification.content.title)
        }
    }

    func removeNotifications(name: String) {
        let center = UNUserNotificationCenter.current()
        var ids = [String]()
        for notifiation in notifications {
            ids.append(notifiation.content.title)
        }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
