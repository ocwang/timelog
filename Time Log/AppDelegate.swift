//
//  AppDelegate.swift
//  Time Log
//
//  Created by Chase Wang on 1/14/17.
//  Copyright © 2017 ocwang. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack(modelName: "TimeLog")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let navController = window?.rootViewController as? UINavigationController,
            let viewController = navController.topViewController as? ViewController {
            viewController.managedContext = coreDataStack.managedContext
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataStack.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
}

