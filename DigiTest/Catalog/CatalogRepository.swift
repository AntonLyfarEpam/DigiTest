//
//  CatalogRepository.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

protocol CatalogRepository {
    func retrieveItems(lastId: String?, refresh: Bool) -> AnyPublisher<[CatalogItemEntity], Never>
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
    func retrieveItems(
        lastId: String?,
        refresh: Bool
    ) -> AnyPublisher<[CatalogItemEntity], Never> {
        retrieveStoredItems(lastId: lastId)
            .merge(with: retrieveRemoteItems(lastId: lastId, refresh: refresh))
            .eraseToAnyPublisher()
    }

    private func retrieveStoredItems(
        lastId: String?
    ) -> AnyPublisher<[CatalogItemEntity], Never> {
        Just(
            storage
                .fetchItems()
                .map(\.entity)
        )
        .eraseToAnyPublisher()
    }

    private func retrieveRemoteItems(
        lastId: String?,
        refresh: Bool
    ) -> AnyPublisher<[CatalogItemEntity], Never> {
        service
            .fetchItems(lastId: lastId)
            .replaceError(with: [])
            .flatMap { [storage] models in
                Future<[CatalogItemResponseModel], Never> { promise in
                    storage.update(with: models.map(\.dataModel)) { result in
                        if refresh || result == .itemsUpdated {
                            promise(.success(models))
                        } else {
                            promise(.success([]))
                        }
                    }
                }
            }
            .filter { models in
                models.isEmpty == false
            }
            .map { models in
                models.map(\.entity)
            }
            .eraseToAnyPublisher()
    }

    private func updateStorage(
        with models: [CatalogItemResponseModel]
    ) -> AnyPublisher<[CatalogItemResponseModel], Never> {
        Future { [storage] promise in
            storage.update(with: models.map(\.dataModel)) { result in
                promise(.success(result == .itemsUpdated ? models : []))
            }
        }
        .eraseToAnyPublisher()
    }
}

struct CatalogItemEntity: Codable {
    let id: String
    let text: String
    let image: URL?
    let confidence: Float
}

private extension CatalogItemResponseModel {
    var dataModel: CatalogItemDataModel {
        .init(id: id, text: text, image: image, confidence: confidence)
    }

    var entity: CatalogItemEntity {
        .init(id: id, text: text, image: URL(string: image), confidence: confidence)
    }
}

private extension CatalogItemDataModel {
    var entity: CatalogItemEntity {
        .init(id: id, text: text, image: imageURL, confidence: confidence)
    }

    private var imageURL: URL? {
        guard let image else { return nil }

        return URL(string: image)
    }
}
