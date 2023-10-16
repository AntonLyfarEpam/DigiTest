//
//  CatalogService.swift
//  DigiTest
//
//  Created by Anton Lyfar on 16.10.2023.
//

import Foundation
import Combine

protocol CatalogService {
    func fetchItems() -> AnyPublisher<[CatalogItemsResponse.Item], Error>
}

class DefaultCatalogService {

}

extension DefaultCatalogService: CatalogService {
    func fetchItems() -> AnyPublisher<[CatalogItemsResponse.Item], Error> {
        Request.execute(
            url: URL(string: "https://marlove.net/e/mock/v1/items")!
        )
        .mapError { $0 }
        .eraseToAnyPublisher()
    }
}

struct CatalogItemsResponse: Codable {
    let items: [Item]

    struct Item: Codable {
        let id: String
        let text: String
        let image: URL
        let confidence: Float

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case text
            case image
            case confidence
        }
    }
}

enum Authorization {
    static let field = "Authorization"
    static let token = <#Your Authorization Token#>
}

enum Request {
    static func execute<T: Codable>(
        url: URL,
        queryItems: [URLQueryItem]? = nil
    ) -> AnyPublisher<T, RequestError> {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            return Fail(error: .badRequest).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.setValue(Authorization.token, forHTTPHeaderField: Authorization.field)

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .retry(2)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw RequestError.badResponse()
                }

                guard httpResponse.statusCode == 200 else {
                    throw RequestError.badResponse(code: httpResponse.statusCode)
                }

                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { _ in
                RequestError.decodingError
            }
            .eraseToAnyPublisher()
    }
}

enum RequestError: Error {
    case badRequest
    case badResponse(code: Int? = nil)
    case decodingError
}
