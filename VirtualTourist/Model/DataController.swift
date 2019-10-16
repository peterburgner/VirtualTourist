//
//  DataController.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/15/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext { return persistentContainer.viewContext }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?() // call optional function to be executed on load
        }
    }
}
