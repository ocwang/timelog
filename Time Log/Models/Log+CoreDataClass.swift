//
//  Log+CoreDataClass.swift
//  Time Log
//
//  Created by Chase Wang on 1/18/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import Foundation
import CoreData

enum ManagedObjectResult {
    case success(NSManagedObject)
    case error(NSError)
}

public class Log: NSManagedObject {
    
    // MARK: - Init
    
    convenience init(title: String, start startDateTime: NSDate, end endDateTime: NSDate, in managedContext: NSManagedObjectContext) {
        self.init(context: managedContext)
        self.title = title
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
    }
}

extension NSManagedObject {
    func insert(into managedContext: NSManagedObjectContext, completionHandler: (ManagedObjectResult) -> Void)  {
        do {
            try managedContext.save()
        } catch let error as NSError {
            completionHandler(.error(error))
        }
        
        completionHandler(.success(self))
    }
}
