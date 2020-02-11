//
//  Stopwatch+CoreDataProperties.swift
//  Timers
//
//  Created by Danil Kurilo on 10.02.2020.
//  Copyright © 2020 Danil Kurilo. All rights reserved.
//
//

import Foundation
import CoreData


extension Stopwatch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stopwatch> {
        return NSFetchRequest<Stopwatch>(entityName: "Stopwatch")
    }

    @NSManaged public var isFinished: Bool
    @NSManaged public var isRunning: Bool
    @NSManaged public var name: String?
    @NSManaged public var breakDate: Date?
    @NSManaged public var counter: Double
    @NSManaged public var finishedTimeString: String?

}
