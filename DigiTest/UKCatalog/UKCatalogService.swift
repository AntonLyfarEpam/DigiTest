//
//  UKCatalogService.swift
//  DigiTest
//
//  Created by Anton Lyfar on 22.10.2023.
//

import Foundation

protocol UKCatalogService {
    func requestItems(maxId: String?, completion: @escaping (Result<[CatalogItemResponseModel], Error>) -> Void)
}

class UKDefaultCatalogService: UKCatalogService {
    func requestItems(maxId: String?, completion: @escaping (Result<[CatalogItemResponseModel], Error>) -> Void) {
        ApiRequest.execute(
            url: URL(string: "https://marlove.net/e/mock/v1/items")!,
            queryItems: ApiRequest.queryItems(maxId: maxId),
            result: { (result: Result<[CatalogItemResponseModel], ApiRequest.RequestError>) in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}

extension ApiRequest {
    static func execute<T: Codable>(
        url: URL,
        queryItems: [URLQueryItem]? = nil,
        result: @escaping (Result<T, RequestError>) -> Void
    ) {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            result(.failure(.badRequest))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(Authorization.token, forHTTPHeaderField: Authorization.field)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, let data else {
                result(.failure(.badResponse()))
                return
            }

            guard httpResponse.statusCode == 200 else {
                result(.failure(.badResponse(code: httpResponse.statusCode)))
                return
            }

            guard let object = try? JSONDecoder().decode(T.self, from: data) else {
                result(.failure(.decodingError))
                return
            }

            result(.success(object))
        }.resume()
    }
}
