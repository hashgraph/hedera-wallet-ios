//
//  CoreDataManager.swift
//  HGCApp
//
//  Created by Surendra  on 23/11/17.
//  Copyright © 2017 HGC. All rights reserved.
//

import UIKit
import CoreData

protocol CoreDataManagerProtocol {
    var mainContext : NSManagedObjectContext {get}
    func saveContext ()

    //func createNewBackgroundContext() -> NSManagedObjectContext
    //func saveBackgroundContext(_ bgContext:NSManagedObjectContext)
}

class CoreDataManager : CoreDataManagerProtocol {

    static let shared : CoreDataManager = CoreDataManager();

    @available(iOS 10.0, *)
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "hgc")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var mainContext: NSManagedObjectContext {
        let managedObjectContext = persistentContainer.viewContext
        return managedObjectContext
    }

    // MARK: - Core Data Saving support
    func saveContext () {
        CoreDataManager.save(context: mainContext)
    }

    @objc func managedObjectContextObjectsDidSave(notification: Notification) {
        self.mainContext.perform {
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }

    static func save(context:NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func clear() throws {
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else {
            return
        }
        
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        do {
            try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
             print("Attempted to clear persistent store: " + error.localizedDescription)
            throw error
          }
    }
}
