//
//  UKCatalogViewModel.swift
//  DigiTest
//
//  Created by Anton Lyfar on 22.10.2023.
//

import Foundation

final class UKCatalogViewModel {
    var onUpdate: ([Item]) -> Void

    private let repository: UKCatalogRepository
    private var currentLastId: String?

    init(
        with repository: UKCatalogRepository = UKDefaultCatalogRepository(),
        onUpdate: @escaping ([Item]) -> Void
    ) {
        self.repository = repository
        self.onUpdate = onUpdate

        loadItems()
    }

    func refresh() {
        loadItems(refresh: true)
    }

    func lastItemShown() {
        loadItems(maxId: currentLastId)
    }

    private func loadItems(maxId: String? = nil, refresh: Bool = false) {
        repository.requestItems(maxId: maxId, refresh: refresh) { [weak self] entities in
            DispatchQueue.main.async {
                self?.onUpdate(entities.map(\.item))
                self?.currentLastId = entities.last?.id
            }
        }
    }
}

extension UKCatalogViewModel {
    struct State {
        let items: [Item]
        let isLoading: Bool
    }

    struct Item: Identifiable, Hashable {
        let id: String
        let text: String
        let image: URL?
        let confidence: Float
    }
}

private extension CatalogItemEntity {
    var item: UKCatalogViewModel.Item {
        .init(id: id, text: text, image: image, confidence: confidence)
    }
}

