//
//  AppDelegate.swift
//  Timers
//
//  Created by Danil Kurilo on 07.02.2020.
//  Copyright © 2020 Danil Kurilo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        
        let persistenceManager = PersistenceManager()
        if let mainViewController = window?.rootViewController as? MainViewController {
          mainViewController.persistenceManager = persistenceManager
        }
        
        return true
    }

  


}

