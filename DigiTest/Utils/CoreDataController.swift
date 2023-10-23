//
//  CoreDataController.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import CoreData

struct CoreDataController {
    static let shared = CoreDataController()

    let managedContext: NSManagedObjectContext
    let privateContext: NSManagedObjectContext

    private let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "DigiTest")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        managedContext = container.viewContext
        privateContext = container.newBackgroundContext()
    }
}
