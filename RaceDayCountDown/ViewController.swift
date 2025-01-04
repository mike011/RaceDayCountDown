//
//  ViewController.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2017-07-29.
//  Copyright © 2017 charland. All rights reserved.
//

import os.log
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var table: UITableView!
    var races = Races()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(races.raceInfos.count)
        return races.raceInfos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let raceInfo = races.raceInfos[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RaceViewCell
        cell.view = self
        cell.race.text = raceInfo.raceName
        cell.indexPath = indexPath

        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: raceInfo.raceDay)
        let days = diff.day!
        if days < 0 || diff.minute! < 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            cell.day.text = dateFormatter.string(from: raceInfo.raceDay)
            cell.day.textColor = UIColor.green
            cell.race.textColor = UIColor.green
        } else if days > 10 {
            cell.day.text = "\(String(describing: diff.day!)) days to go"
        } else if days == 0 {
            var stringHours = "hour"
            if diff.hour! > 1 {
                stringHours += "s"
            }
            var stringMinutes = "minutes"
            if diff.minute! > 1 {
                stringMinutes += "s"
            }
            cell.day.text = "\(String(describing: diff.hour!)) \(stringHours) \(String(describing: diff.minute!)) \(stringMinutes)"
        } else if days < 3 {
            var stringDays = "day"
            if days > 1 {
                stringDays += "s"
            }
            var stringHours = "hour"
            if diff.hour! > 1 {
                stringHours += "s"
            }
            var stringMinutes = "minutes"
            if diff.minute! > 1 {
                stringMinutes += "s"
            }
            cell.day.text = "\(String(describing: diff.day!)) \(stringDays) \(String(describing: diff.hour!)) \(stringHours) \(String(describing: diff.minute!)) \(stringMinutes)"
        } else {
            var stringHours = "hour"
            if diff.hour! > 1 {
                stringHours += "s"
            }
            cell.day.text = "\(String(describing: diff.day!)) days \(String(describing: diff.hour!)) \(stringHours)"
        }

        return cell
    }

    func deleteRace(_ indexPath: IndexPath) {
        races.remove(at: indexPath.row)
        table.beginUpdates()
        table.deleteRows(at: [indexPath], with: .automatic)
        table.endUpdates()
        races.save()
        table.reloadData()
    }
}

#Preview {
    createViewController()
}

@MainActor
func createViewController() -> ViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
    vc.races.add(race: RaceInfo(race: "Caledon Crusher", day: getDate(from: "2025-04-16")))
    vc.races.add(race: RaceInfo(race: "The Bad Thing", day: getDate(from: "2023-10-21")))
    vc.loadViewIfNeeded()
    return vc
}

private func getDate(from string: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = string
    let date = dateFormatter.date(from: dateString)
    return date!
}
