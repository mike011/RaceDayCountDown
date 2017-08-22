//
//  Races.swift
//  RaceDayCountDown
//
//  Created by Michael Charland on 2017-08-17.
//  Copyright © 2017 charland. All rights reserved.
//

import Foundation
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

class Races {
    var races = [RaceInfo]()

    init() {
        races = load()!
    }

    func add(race: String , day: Date) {
        races.append(RaceInfo(race: race, day: day))
    }

    func remove(at : Int) {
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
        races = races.sorted{ $0.day < $1.day }
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(races, toFile: RaceInfo.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Races successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save races...", log: OSLog.default, type: .error)
        }
    }
}
