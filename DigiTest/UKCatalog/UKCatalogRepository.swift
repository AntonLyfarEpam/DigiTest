//
//  UKCatalogRepository.swift
//  DigiTest
//
//  Created by Anton Lyfar on 22.10.2023.
//

import Foundation

protocol UKCatalogRepository {
    func requestItems(maxId: String?, refresh: Bool, completion: @escaping ([CatalogItemEntity]) -> Void)
}

class UKDefaultCatalogRepository {
    private let service: UKCatalogService
    private let storage: CatalogStorage

    init(
        service: UKCatalogService = UKDefaultCatalogService(),
        storage: CatalogStorage = DefaultCatalogStorage()
    ) {
        self.service = service
        self.storage = storage
    }
}

extension UKDefaultCatalogRepository: UKCatalogRepository {
    func requestItems(maxId: String?, refresh: Bool, completion: @escaping ([CatalogItemEntity]) -> Void) {
        completion(storage.fetchItems().map(\.entity))
        service.requestItems(maxId: maxId) { [storage] result in
            let items: [CatalogItemResponseModel]

            switch result {
            case .success(let response): items = response
            case .failure: items = []
            }

            storage.update(with: items.map(\.dataModel)) { result in
                if refresh || result == .itemsUpdated {
                    let entities = storage.fetchItems().map(\.entity)
                    completion(entities)
                }
            }
        }
    }
}
