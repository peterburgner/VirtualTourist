//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/8/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsMapController = navigationController.topViewController as! TravelLocationsMapController
        travelLocationsMapController.dataController = dataController
        
        return true
    }

}

