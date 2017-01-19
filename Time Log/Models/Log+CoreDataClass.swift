//
//  Log+CoreDataClass.swift
//  Time Log
//
//  Created by Chase Wang on 1/18/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import Foundation
import CoreData

public class Log: NSManagedObject {
    
    // MARK: - Init
    
    convenience init(title: String, start startDateTime: NSDate, end endDateTime: NSDate, in managedContext: NSManagedObjectContext) {
        self.init(context: managedContext)
        self.title = title
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
    }
}


