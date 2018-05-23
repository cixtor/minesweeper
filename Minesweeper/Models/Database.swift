//
//  Database.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import CoreData

typealias GetPersistentContainerHandler = (_ container: NSPersistentContainer?) -> Void

class Database {
    private(set) var persistentContainer: NSPersistentContainer?
    
    private(set) var backgroundManagedObjectContext: NSManagedObjectContext?
    
    private(set) var mainManagedObjectContext: NSManagedObjectContext?
    
    private(set) lazy var memoryManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedObjectContext.parent = self.backgroundManagedObjectContext
        
        return managedObjectContext
    }()
    
    init(name: String, managedObjectModel: NSManagedObjectModel? = nil) {
        Database.getPersistentContainer(name: name, managedObjectModel: managedObjectModel) { container in
            guard let container = container else { return }
            
            self.persistentContainer = container
            
            self.mainManagedObjectContext = container.viewContext
            self.mainManagedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            let backgroundContext = container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.backgroundManagedObjectContext = backgroundContext
            
            self.memoryManagedObjectContext.parent = backgroundContext
        }
    }
    
    func commitAllChangesToDisk() {
        guard let backgroundContext = self.backgroundManagedObjectContext else {
            return
        }
        
        if self.memoryManagedObjectContext.parent == nil {
            self.memoryManagedObjectContext.parent = backgroundContext
        }
        
        self.memoryManagedObjectContext.perform {
            do {
                if self.memoryManagedObjectContext.hasChanges {
                    try self.memoryManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to save changes of managed object context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
            backgroundContext.perform {
                do {
                    if backgroundContext.hasChanges {
                        try backgroundContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to save changes of private managed object context")
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            }
        }
    }
    
    static func getPersistentContainer(name: String, managedObjectModel: NSManagedObjectModel? = nil, handler: @escaping GetPersistentContainerHandler) {
        var container: NSPersistentContainer
        
        if let managedObjectModel = managedObjectModel {
            container = NSPersistentContainer(name: name, managedObjectModel: managedObjectModel)
        } else {
            container = NSPersistentContainer(name: name)
        }
        
        container.loadPersistentStores { (_, error) in
            guard error == nil else {
                handler(nil)
                return
            }
            
            return handler(container)
        }
    }
    
    static func getManagedObjectModel(name: String) -> NSManagedObjectModel? {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                return nil
        }
        
        return managedObjectModel
    }
}
