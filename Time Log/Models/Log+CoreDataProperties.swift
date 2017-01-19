//
//  Log+CoreDataProperties.swift
//  Time Log
//
//  Created by Chase Wang on 1/18/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import Foundation
import CoreData


extension Log {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Log> {
        return NSFetchRequest<Log>(entityName: "Log");
    }

    @NSManaged public var startDateTime: NSDate?
    @NSManaged public var endDateTime: NSDate?
    @NSManaged public var title: String?

}
