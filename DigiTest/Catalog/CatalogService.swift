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

class DefaultCatalogService {

}

extension DefaultCatalogService: CatalogService {
    func fetchItems(lastId: String?) -> AnyPublisher<[CatalogItemResponseModel], Error> {
        ApiRequest.execute(
            url: URL(string: "https://marlove.net/e/mock/v1/items")!,
            queryItems: [URLQueryItem(name: "since_id", value: lastId)]
        )
        .mapError { $0 }
        .eraseToAnyPublisher()
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
