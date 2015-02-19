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
    let store:NSPersistentStore?
    
    init() {
        //1
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource("HitList", withExtension:"momd")
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        //1.1
        CBLIncrementalStore.updateManagedObjectModel(model)
        
        //2
        psc = NSPersistentStoreCoordinator(managedObjectModel:model)
        
        //3
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = psc
        
        //4
        let documentsURL = applicationDocumentsDirectory()
        let storeURL = documentsURL.URLByAppendingPathComponent("HitList")
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        
        
        let databaseName = "String"
        if !(CBLManager.sharedInstance().existingDatabaseNamed(databaseName, error: nil) != nil) {
            let importStore = psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: nil)
            store = psc.migratePersistentStore(importStore, toURL: <#NSURL#>, options: <#[NSObject : AnyObject]?#>, withType: <#String#>, error: <#NSErrorPointer#>)
        }
        
        var error: NSError? = nil
        store = psc.addPersistentStoreWithType(CBLIncrementalStore.type(), configuration: nil, URL: storeURL, options: options, error: &error)
        
//        store = psc.addPersistentStoreWithType(NSSQLiteStoreType,
//            configuration: nil,
//            URL: storeURL,
//            options: options,
//            error:&error)
//        
        if store == nil {
            println("Error adding persistent store: \(error)")
            abort()
        }
        
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