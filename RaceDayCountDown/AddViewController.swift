//
//  AddViewController.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2017-08-16.
//  Copyright © 2017 charland. All rights reserved.
//

import os.log
import UIKit
import UserNotifications

// delete nofications
class AddViewController: UIViewController {
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var raceName: UITextField!
    var raceInfo: RaceInfo!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        if raceInfo != nil {
            raceName.text = raceInfo.raceName
            datePicker.date = raceInfo.raceDay
        }
    }

    @IBAction func addRace(_ sender: Any) {
        let name = raceName.text
        guard (name?.count)! > 0 else {
            let alert = UIAlertController(title: "Alert", message: "Name Can't Be Empty", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let races = Races()
        raceInfo = RaceInfo(race: name!, day: datePicker.date)
        races.add(race: raceInfo)
        races.save()
        raceInfo.scheduleNotifications()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func createDate(day: Int) -> DateComponents {
        var date = DateComponents()
        date.day = day
        return date
    }
}

#Preview {
    createAddViewController()
}

@MainActor
func createAddViewController() -> AddViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
    vc.loadViewIfNeeded()
    return vc
}
