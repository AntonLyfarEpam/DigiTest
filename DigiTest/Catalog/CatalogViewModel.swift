//
//  CatalogViewModel.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

final class CatalogViewModel: ObservableObject {
    @Published var items = [Item]()
    @Published var isLoading = false

    private let repository: CatalogRepository

    private var currentLastId: String?
    private var itemsSubscription: AnyCancellable?

    init(with repository: CatalogRepository = DefaultCatalogRepository()) {
        self.repository = repository

        loadItems()
    }

    func refresh() {
        loadItems(refresh: true)
    }

    func lastItemShown() {
        loadItems(maxId: currentLastId)
    }

    private func loadItems(maxId: String? = nil, refresh: Bool = false) {
        isLoading = true
        itemsSubscription = repository
            .retrieveItems(maxId: maxId, refresh: refresh)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entities in
                self?.items = entities.map(\.item)
                self?.currentLastId = entities.last?.id
                self?.isLoading = false
            }
    }
}

extension CatalogViewModel {
    struct Item: Identifiable, Hashable {
        let id: String
        let text: String
        let image: URL?
        let confidence: Float
    }
}


private extension CatalogItemEntity {
    var item: CatalogViewModel.Item {
        .init(id: id, text: text, image: image, confidence: confidence)
    }
}
