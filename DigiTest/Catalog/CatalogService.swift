//
//  CatalogService.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

protocol CatalogService {
    func fetchItems(lastId: String?) -> AnyPublisher<[CatalogItemResponseModel], Error>
}

class DefaultCatalogService: CatalogService {
    func fetchItems(lastId: String? = nil) -> AnyPublisher<[CatalogItemResponseModel], Error> {
        ApiRequest.execute(
            url: URL(string: "https://marlove.net/e/mock/v1/items")!,
            queryItems: queryItems(lastId: lastId)
        )
        .mapError { $0 }
        .eraseToAnyPublisher()
    }

    private func queryItems(lastId: String?) -> [URLQueryItem] {
        guard let lastId else { return [] }

        return [URLQueryItem(name: "since_id", value: lastId)]
    }
}

struct CatalogItemResponseModel: Codable {
    let id: String
    let text: String
    let image: String
    let confidence: Float

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case image
        case confidence
    }
}
