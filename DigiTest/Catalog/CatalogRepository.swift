//
//  CatalogRepository.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

protocol CatalogRepository {
    func retrieveItems(lastId: String?)
}

class DefaultCatalogRepository {
    private let service: CatalogService
    private let storage: CatalogStorage

    private var subscriptions = Set<AnyCancellable>()

    init(
        service: CatalogService = DefaultCatalogService(),
        storage: CatalogStorage = DefaultCatalogStorage()
    ) {
        self.service = service
        self.storage = storage
    }
}

extension DefaultCatalogRepository: CatalogRepository {
    func retrieveItems(lastId: String?) {
        DefaultCatalogService()
            .fetchItems(lastId: lastId)
            .replaceError(with: [])
            .sink { response in
                let items = response.map { item in
                    DefaultCatalogStorage.ItemDataModel(
                        id: item.id,
                        text: item.text,
                        image: item.image,
                        confidence: item.confidence
                    )
                }

                self.storage.save(items: items)
            }
            .store(in: &subscriptions)
    }
}
