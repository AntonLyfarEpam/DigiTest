//
//  CatalogStorage.swift
//  DigiTest
//
//  Created by Anton Lyfar on 17.10.2023.
//

import Foundation
import CoreData

protocol CatalogStorage {
    func fetchItems() -> [CatalogItemDataModel]
    func update(with items: [CatalogItemDataModel])
}

class DefaultCatalogStorage: CatalogStorage {
    func fetchItems() -> [CatalogItemDataModel] {
        let context = CoreDataController.shared.managedContext
        guard let items = try? context.fetch(Item.fetchRequest()) else { return [] }

        return items.compactMap(\.dataModel)
    }

    func update(with items: [CatalogItemDataModel]) {
        let context = CoreDataController.shared.privateContext

        context.performAndWait {
            let request = NSBatchInsertRequest(entityName: "Item", objects: encode(items: items))
            request.resultType = .objectIDs

            do {
                let result = try context.execute(request)
                let insertResult = result as? NSBatchInsertResult
                let ids = insertResult?.result as? [NSManagedObjectID]
                let isUpdated = ids?.isEmpty == false

//                onCompletion(isUpdated ? .itemsUpdated : .noChanges)

            } catch let error as NSError {
                print(error.localizedDescription)
//                onCompletion(.storageError)
            }
        }
    }

    private func encode(items: [CatalogItemDataModel]) -> [[String:Any]] {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(items) else { return [] }

        let itemsArray = try? JSONSerialization.jsonObject(
            with: jsonData as Data,
            options: JSONSerialization.ReadingOptions.mutableContainers
        ) as? [[String:Any]]

        return itemsArray ?? []
    }
}

enum StorageUpdateResult {
    case noChanges
    case itemsUpdated
    case storageError
}

struct CatalogItemDataModel: Codable {
    let id: String
    let text: String
    let image: String?
    let confidence: Float
}

private extension Item {
    var dataModel: CatalogItemDataModel? {
        guard let id, let text else { return nil }

        return .init(
            id: id,
            text: text,
            image: image,
            confidence: confidence
        )
    }
}
