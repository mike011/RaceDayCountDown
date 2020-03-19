//
//  Races.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2017-08-17.
//  Copyright © 2017 charland. All rights reserved.
//

import Foundation
import os.log

class Races {
    var races = [RaceInfo]()

    init() {
        self.races = load()!
    }

    func add(race: RaceInfo) {
        races.append(race)
    }

    func remove(at: Int) {
        races[at].removeNotifications()
        races.remove(at: at)
    }

    private func load() -> [RaceInfo]? {
        let r = NSKeyedUnarchiver.unarchiveObject(withFile: RaceInfo.ArchiveURL.path) as? [RaceInfo]
        if r == nil {
            return [RaceInfo]()
        }
        return r
    }

    func save() {
        races = races.sorted { $0.raceDay < $1.raceDay }
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(races, toFile: RaceInfo.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Races successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save races...", log: OSLog.default, type: .error)
        }
    }
}
