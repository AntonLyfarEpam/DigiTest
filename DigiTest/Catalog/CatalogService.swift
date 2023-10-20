//
//  CatalogService.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

protocol CatalogService {
    func fetchItems(maxId: String?) -> AnyPublisher<[CatalogItemResponseModel], Error>
}

class DefaultCatalogService: CatalogService {
    func fetchItems(maxId: String?) -> AnyPublisher<[CatalogItemResponseModel], Error> {
        ApiRequest.execute(
            url: URL(string: "https://marlove.net/e/mock/v1/items")!,
            queryItems: queryItems(maxId: maxId)
        )
        .mapError { $0 }
        .eraseToAnyPublisher()
    }

    private func queryItems(maxId: String?) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        if let maxId { queryItems.append(URLQueryItem(name: "max_id", value: maxId)) }

        return queryItems
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
