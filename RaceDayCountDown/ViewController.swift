//
//  ViewController.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2017-07-29.
//  Copyright © 2017 charland. All rights reserved.
//

import UIKit
import os.log

struct PropertyKey {
    static let race = "race"
    static let day = "day"
}

class RaceInfo: NSObject, NSCoding {

    let race : String
    let day : Date

    required convenience init?(coder aDecoder: NSCoder) {
        guard let race = aDecoder.decodeObject(forKey: PropertyKey.race) as? String else {
            os_log("Unable to decode the race for a Race object.", log: OSLog.default, type: .debug)
            return nil
        }
        let day = aDecoder.decodeObject(forKey: PropertyKey.day) as! Date
        self.init(race: race, day: day)
    }

    init(race: String, day: Date) {
        self.race = race
        self.day = day
    }

    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(race, forKey: PropertyKey.race)
        aCoder.encode(day, forKey: PropertyKey.day)
    }

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("races")
}

class RaceViewCell: UITableViewCell {
    @IBOutlet weak var race: UILabel!
    @IBOutlet weak var day: UILabel!
    var view: ViewController!
    var indexPath: IndexPath!

    @IBAction func edit(_ sender: Any) {
        let raceInfo = view.races[indexPath.row]
        view.raceName.text = raceInfo.race
        view.datePicker.date = raceInfo.day
        deleteRace()
    }
    @IBAction func deleteButton(_ sender: Any) {
        deleteRace()
    }

    func deleteRace() {
        view.races.remove(at: indexPath.row)
        view.table.beginUpdates()
        view.table.deleteRows(at: [indexPath], with: .automatic)
        view.table.endUpdates()
        view.saveRaces()
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    var races = [RaceInfo]()
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var raceName: UITextField!

    override func viewDidLoad() {
        races = loadRaces()!
        races = races.sorted{ $0.day < $1.day }
        super.viewDidLoad()
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

        races.append(RaceInfo(race: name!, day: datePicker.date))
        table.beginUpdates()
        table.insertRows(at: [IndexPath(row: races.count - 1, section: 0)], with: .automatic)
        table.endUpdates()


        races = races.sorted{ $0.day < $1.day }
        saveRaces()
        table.reloadData()

        datePicker.setDate(Date(), animated: false)
        raceName.text = ""
    }

    func saveRaces() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(races, toFile: RaceInfo.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Races successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save races...", log: OSLog.default, type: .error)
        }
    }

    private func loadRaces() -> [RaceInfo]? {
        let r = NSKeyedUnarchiver.unarchiveObject(withFile: RaceInfo.ArchiveURL.path) as? [RaceInfo]
        if r == nil {
            return [RaceInfo]()
        }
        return r
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return races.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let raceInfo = races[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RaceViewCell
        cell.view = self
        cell.race.text = raceInfo.race
        cell.indexPath = indexPath

        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: raceInfo.day)
        let days = diff.day!
        if days < 0 || diff.minute! < 0 {
            cell.day.text = raceInfo.day.description
            cell.day.textColor = UIColor.green
        } else if days > 10 {
            cell.day.text = "\(String(describing: diff.day!)) days"
        } else if days == 0 {
            var stringHours = "hour"
            if(diff.hour! > 1) {
                stringHours += "s"
            }
            var stringMinutes = "minutes"
            if(diff.minute! > 1) {
                stringMinutes += "s"
            }
            cell.day.text = "\(String(describing: diff.hour!)) \(stringHours) \(String(describing: diff.minute!)) \(stringMinutes)"
        } else if days < 3 {
            var stringDays = "day"
            if(days > 1) {
                stringDays += "s"
            }
            var stringHours = "hour"
            if(diff.hour! > 1) {
                stringHours += "s"
            }
            var stringMinutes = "minutes"
            if(diff.minute! > 1) {
                stringMinutes += "s"
            }
            cell.day.text = "\(String(describing: diff.day!)) \(stringDays) \(String(describing: diff.hour!)) \(stringHours) \(String(describing: diff.minute!)) \(stringMinutes)"
        } else {
            var stringHours = "hour"
            if(diff.hour! > 1) {
                stringHours += "s"
            }
            cell.day.text = "\(String(describing: diff.day!)) days \(String(describing: diff.hour!)) \(stringHours)"

        }

        return cell
    }
}

