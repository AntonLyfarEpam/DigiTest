//
//  CatalogRepository.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

protocol CatalogRepository {
    func f()
}

class DefaultCatalogRepository {
    private var subscriptions = Set<AnyCancellable>()

    func f() {
        DefaultCatalogService()
            .fetchItems()
            .sink(receiveCompletion: { _ in

            }, receiveValue: { response in

            })
            .store(in: &subscriptions)
    }
}

extension DefaultCatalogRepository: CatalogRepository {

}
