//
//  CoreDataStack.swift
//  HitList
//
//  Created by James Nocentini on 19/02/2015.
//  Copyright (c) 2015 James Nocentini. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    let context:NSManagedObjectContext
    let psc:NSPersistentStoreCoordinator
    let model:NSManagedObjectModel
    let store:CBLIncrementalStore?
    
    init() {
        //1
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("HitList", withExtension:"momd")
        model = NSManagedObjectModel.mergedModelFromBundles(nil)!.mutableCopy() as NSManagedObjectModel
        
        //1.1
        CBLIncrementalStore.updateManagedObjectModel(model)
        
        //2
        psc = NSPersistentStoreCoordinator(managedObjectModel:model)
        
        //3
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = psc
        
        //4
        let documentsURL = applicationDocumentsDirectory()
        let defaultStoreURL = documentsURL.URLByAppendingPathComponent("HitList")
        
        let options: NSDictionary = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let databaseName = "hitlist"
        let storeURL = NSURL(string: databaseName)!
        var error: NSError? = nil
        
        if (!(CBLManager.sharedInstance().existingDatabaseNamed(databaseName, error: nil) != nil)) {
//            let defaultStoreURL = bundle.URLForResource("HitList", withExtension: "sqlite")
            let importStore = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: defaultStoreURL, options: options, error: nil)
            store = psc.migratePersistentStore(importStore!, toURL: storeURL, options: options, withType: CBLIncrementalStore.type(), error: nil) as CBLIncrementalStore
        } else {
            store = psc.addPersistentStoreWithType(CBLIncrementalStore.type(), configuration: nil, URL: storeURL, options: options, error: &error) as CBLIncrementalStore
        }
        
//        store = psc.addPersistentStoreWithType(NSSQLiteStoreType,
//            configuration: nil,
//            URL: storeURL,
//           options: options,
//            error:&error)
//        
        if store == nil {
            println("Error adding persistent store: \(error)")
            abort()
        }
        
        let url =  NSURL(string: "http://178.62.81.153:4984/hitlist/")
        let pull = store?.database.createPullReplication(url)
        let push = store?.database.createPushReplication(url)
        
        pull?.start()
        push?.start()
        
    }
    
    func saveContext() {
        var error: NSError? = nil
        if context.hasChanges && !context.save(&error) {
            println("Could not save: \(error), \(error?.userInfo)")
        }
    }
    
    func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory,
            inDomains: .UserDomainMask) as [NSURL]
        
        return urls[0]
    }
    
}