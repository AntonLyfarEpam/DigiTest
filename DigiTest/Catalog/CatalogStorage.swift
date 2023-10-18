//
//  CatalogStorage.swift
//  DigiTest
//
//  Created by Anton Lyfar on 17.10.2023.
//

import Foundation
import CoreData

protocol CatalogStorage {

}

class DefaultCatalogStorage {
    func fetchItems() -> [ItemDataModel] {
        let context = CoreDataController.shared.managedContext
        let items = try? context.fetch(Item.fetchRequest())
        let itemDataModels = items?.map { item in
            ItemDataModel(
                id: item.id!,
                text: item.text!,
                image: item.image!,
                confidence: item.confidence
            )
        }

        return itemDataModels ?? []
    }

    func save(items: [ItemDataModel]) {
        let context = CoreDataController.shared.privateContext

        context.performAndWait {
            let request = NSBatchInsertRequest(entityName: "Item", objects: encode(items: items))
            request.resultType = .objectIDs
            do {
                let result = try context.execute(request)
                let insertResult = result as? NSBatchInsertResult
                let ids = insertResult?.result as? [NSManagedObjectID]
                print(result as? NSBatchInsertResult)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

    private func encode(items: [ItemDataModel]) -> [[String:Any]] {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(items) else { return [] }

        let itemsArray = try? JSONSerialization.jsonObject(
            with: jsonData as Data,
            options: JSONSerialization.ReadingOptions.mutableContainers
        ) as? [[String:Any]]

        return itemsArray ?? []
    }
}

extension DefaultCatalogStorage: CatalogStorage {
    struct ItemDataModel: Codable {
        let id: String
        let text: String
        let image: String
        let confidence: Float
    }
}
