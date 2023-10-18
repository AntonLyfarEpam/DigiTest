//
//  CatalogRepository.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

protocol CatalogRepository {
    func retrieveItems(lastId: String?) -> AnyPublisher<[CatalogItemEntity], Never>
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
    func retrieveItems(lastId: String?) -> AnyPublisher<[CatalogItemEntity], Never> {
        Just(
            storage
                .fetchItems()
                .map(\.entity)
        )
        .merge(with: retrieveRemoteItems(lastId: lastId))
        .eraseToAnyPublisher()
    }

    private func retrieveRemoteItems(lastId: String?) -> AnyPublisher<[CatalogItemEntity], Never> {
        service
            .fetchItems(lastId: lastId)
            .replaceError(with: [])
            .handleEvents(receiveOutput: { [storage] models in
                storage.update(with: models.map(\.dataModel))
            })
//            .flatMap { [storage] models in
//                Deferred {
//                    Future<[CatalogItemResponseModel], Never> { promise in
//                        storage.update(with: models.map(\.dataModel)) { result in
//                            switch result {
//                            case .noChanges:
//                                promise(.success([]))
//                            case .itemsUpdated:
//                                promise(.success(models))
//                            case .storageError:
//                                promise(.success([]))
//                            }
//                        }
//                    }
//                }
//            }
//            .filter { models in
//                models.isEmpty == false
//            }
            .map {
                let items =
                $0.map { item in
                    CatalogItemEntity(
                        id: item.id,
                        text: item.text,
                        image: URL(string: item.image),
                        confidence: item.confidence
                    )
                }

                return [items.first].compactMap { $0 }
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
        .init(
            id: id,
            text: text,
            image: image,
            confidence: confidence
        )
    }
}

private extension CatalogItemDataModel {
    var entity: CatalogItemEntity {
        .init(
            id: id,
            text: text,
            image: imageURL,
            confidence: confidence
        )
    }

    private var imageURL: URL? {
        guard let image else { return nil }

        return URL(string: image)
    }
}
