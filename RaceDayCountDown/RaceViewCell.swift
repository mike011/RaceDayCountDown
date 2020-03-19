//
//  RaceViewCell.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2017-08-20.
//  Copyright © 2017 charland. All rights reserved.
//

import Foundation
import UIKit

class RaceViewCell: UITableViewCell {
    @IBOutlet var race: UILabel!
    @IBOutlet var day: UILabel!
    var view: ViewController!
    var indexPath: IndexPath!

    @IBAction func edit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
        myVC.raceInfo = view.races.races[indexPath.row]
        view.present(myVC, animated: true, completion: nil)
        deleteRace()
    }

    @IBAction func deleteButton(_ sender: Any) {
        deleteRace()
    }

    func deleteRace() {
        view.deleteRace(indexPath)
    }
}
