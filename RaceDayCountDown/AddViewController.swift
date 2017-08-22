//
//  AddViewController.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2017-08-16.
//  Copyright © 2017 charland. All rights reserved.
//

import UIKit
import os.log
import UserNotifications

// delete nofications
class AddViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var raceName: UITextField!
    var raceInfo: RaceInfo!
    public static var intervals = [3,10,25]

    override func viewDidLoad() {
        super.viewDidLoad()

        if raceInfo != nil {
            raceName.text = raceInfo.race
            datePicker.date = raceInfo.day
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addRace(_ sender: Any) {
        let name = raceName.text
        guard (name?.characters.count)! > 0 else {
            let alert = UIAlertController(title: "Alert", message: "Name Can't Be Empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        let races = Races()
        races.add(race: name!, day: datePicker.date)
        races.save()
        createNotifications()
    }

    func createDate(day : Int) -> DateComponents {
        var date = DateComponents()
        date.day = day
        return date
    }

    func createNotifications() {

        let content = UNMutableNotificationContent()
        content.title = raceName.text!
        content.body = "Are you ready?"
        addNotification(content, AddViewController.intervals)
    }

    func addNotification(_ content: UNMutableNotificationContent, _ befores : [Int]) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.scheduleNotifications(content, befores)
            } else {
                // User has not given permissions
                center.requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { (granted, error) in
                    if let error = error {
                        print(error)
                    } else if granted {
                        self.scheduleNotifications(content, befores)
                    }
                })
            }
        }
    }

    static let timedNotifcationIdentifier = "timedNotificationIdentifier"
    let timerGraphic = "timerGraphic"

    func triggerCheck(_ content: UNMutableNotificationContent) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        content.title += " TEST"
        scheduleNotification(content, AddViewController.timedNotifcationIdentifier + raceName.description + String(10), trigger)
    }

    func scheduleNotifications(_ content: UNMutableNotificationContent, _ befores : [Int]) {
        triggerCheck(content)
        for before in befores {
            scheduleTrigger(content, before)
        }
    }

    func intervalIsPositive(_ interval: TimeInterval) -> Bool {
        let isZero = interval.isZero
        let isNegative = interval.isLess(than: 0)
        return !isZero && !isNegative
    }

    static func getTriggerName(name: String, _ before : Int) -> String {
        return timedNotifcationIdentifier + name + String(before)
    }

    func scheduleTrigger(_ content: UNMutableNotificationContent, _ before: Int) {

        content.body += "Only \(before) days left to the race!"
        let daysBefore3 = Calendar.current.date(byAdding: .day, value: -before, to: datePicker.date)

        let interval = daysBefore3?.timeIntervalSinceNow

        if intervalIsPositive(interval!) {
            let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: interval!, repeats: false)
            scheduleNotification(content, AddViewController.getTriggerName(name: raceName.description, before), trigger2)
        }
    }

    func scheduleNotification(_ content: UNMutableNotificationContent, _ name : String, _ trigger : UNNotificationTrigger) {
        let url = Bundle.main.url(forResource: "socks", withExtension: "jpeg")!
        let imageAttachement  = try! UNNotificationAttachment(identifier: timerGraphic, url: url, options: nil)
        content.attachments.append(imageAttachement)

        let notificationRequest = UNNotificationRequest(identifier: name, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(notificationRequest) { (error) in
            if let error = error {
                print(error)
            } else {
                print ("Notification scheduled")
            }
        }
    }

    static func removeNotifications(name: String) {
        let center = UNUserNotificationCenter.current()
        var ids = [String]()
        for interval in intervals {
            ids.append(getTriggerName(name: name, interval))
        }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}