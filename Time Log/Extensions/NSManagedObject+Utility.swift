//
//  NSManagedObject+Utility.swift
//  Time Log
//
//  Created by Chase Wang on 1/19/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import Foundation
import CoreData

enum ManagedObjectResult {
    case success(NSManagedObject)
    case error(NSError)
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
