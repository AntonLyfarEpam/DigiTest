//
//  ApiRequest.swift
//  DigiTest
//
//  Created by Anton Lyfar on 18.10.2023.
//

import Foundation
import Combine

enum Authorization {
    static let field = "Authorization"
    static let token = <#Your Authorization Token#>
}

enum ApiRequest {
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

    enum RequestError: Error {
        case badRequest
        case badResponse(code: Int? = nil)
        case decodingError
    }
}
