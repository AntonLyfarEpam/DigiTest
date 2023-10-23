//
//  CatalogRepository.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

protocol CatalogRepository {
    func retrieveItems(maxId: String?, refresh: Bool) -> AnyPublisher<[CatalogItemEntity], Never>
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
    func retrieveItems(maxId: String?, refresh: Bool) -> AnyPublisher<[CatalogItemEntity], Never> {
        Publishers.Merge(
            retrieveStoredItems(),
            retrieveRemoteItems(maxId: maxId, refresh: refresh)
        )
        .eraseToAnyPublisher()
    }

    private func retrieveStoredItems() -> AnyPublisher<[CatalogItemEntity], Never> {
        Just(storage.fetchItems().map(\.entity))
            .eraseToAnyPublisher()
    }

    private func retrieveRemoteItems(
        maxId: String?,
        refresh: Bool
    ) -> AnyPublisher<[CatalogItemEntity], Never> {
        service
            .fetchItems(maxId: maxId)
            .replaceError(with: [])
            .flatMap { [storage] models in
                Future { promise in
                    storage.update(with: models.map(\.dataModel)) { result in
                        if refresh || result == .itemsUpdated {
                            let entities = storage.fetchItems().map(\.entity)
                            promise(.success(entities))
                        }
                    }
                }
            }
            .filter { $0.isEmpty == false }
            .eraseToAnyPublisher()
    }
}

struct CatalogItemEntity: Codable {
    let id: String
    let text: String
    let image: URL?
    let confidence: Float
}

extension CatalogItemResponseModel {
    var dataModel: CatalogItemDataModel {
        .init(id: id, text: text, image: image, confidence: confidence)
    }

    var entity: CatalogItemEntity {
        .init(id: id, text: text, image: URL(string: image), confidence: confidence)
    }
}

extension CatalogItemDataModel {
    var entity: CatalogItemEntity {
        .init(id: id, text: text, image: imageURL, confidence: confidence)
    }

    private var imageURL: URL? {
        guard let image else { return nil }

        return URL(string: image)
    }
}
