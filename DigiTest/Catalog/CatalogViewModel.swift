//
//  CatalogViewModel.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

final class CatalogViewModel: ObservableObject {
    private let repository: CatalogRepository

    private var subscriptions = Set<AnyCancellable>()

    @Published
    var items = [Item]()

    init(with repository: CatalogRepository = DefaultCatalogRepository()) {
        self.repository = repository
    }
}

extension CatalogViewModel {
    struct Item {
        let id: String
        let text: String
        let image: URL
        let confidence: Float
    }
}
