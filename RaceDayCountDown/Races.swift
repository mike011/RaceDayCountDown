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
    var raceInfos = [RaceInfo]()

    init() {
        self.raceInfos = load()!
    }

    func add(race: RaceInfo) {
        raceInfos.append(race)
    }

    func remove(at: Int) {
        raceInfos[at].removeNotifications()
        raceInfos.remove(at: at)
    }

    private func load() -> [RaceInfo]? {
        let r = NSKeyedUnarchiver.unarchiveObject(withFile: RaceInfo.ArchiveURL.path) as? [RaceInfo]
        if r == nil {
            return [RaceInfo]()
        }
        return r
    }

    func save() {
        raceInfos = raceInfos.sorted { $0.raceDay < $1.raceDay }
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(raceInfos, toFile: RaceInfo.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Races successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save races...", log: OSLog.default, type: .error)
        }
    }
}
