//
//  NetworkManager.swift
//  PhoneBook
//
//  Created by Safarnejad on 7/14/22.
//

import Foundation
import Combine
import UIKit

// MARK: - Network Controller
protocol NetworkManagerProtocol: AnyObject {
    typealias Headers = [String: Any]
    
    func get<T: Decodable>(type: T.Type, url: URL) -> AnyPublisher<T, APIError>
    func post<T: Decodable, U: Encodable>(type: T.Type, url: URL, payload: U) -> AnyPublisher<T, APIError>
    func put<T: Decodable, U: Encodable>(type: T.Type, url: URL, payload: U) -> AnyPublisher<T, APIError>
//    func delete<T: Decodable>(type: T.Type, url: URL) -> AnyPublisher<T, APIError>
    func delete(url: URL) -> AnyPublisher<Bool, APIError>
}

enum APIError: Error {
    case decodingError
    case httpError(Int)
    case unknown
}

class NetworkManager: NetworkManagerProtocol {
    private var cancellables = Set<AnyCancellable>()

    func get<T: Decodable>(type: T.Type, url: URL) -> AnyPublisher<T, APIError> {
        var urlRequest = URLRequest(url: url)
       
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("a5b39dedacbffd95e1421020dae7c8b5ac3cc", forHTTPHeaderField: "x-apikey")
        
//        headers.forEach { (key, value) in
//            if let value = value as? String {
//                urlRequest.setValue(value, forHTTPHeaderField: key)
//            }
//        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .mapError { _ in .unknown }
            .flatMap { data, response -> AnyPublisher<T, APIError> in
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        return Just(data)
                            .decode(type: T.self, decoder: decoder)
                            .mapError {_ in .decodingError}
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: APIError.httpError(response.statusCode))
                            .eraseToAnyPublisher()
                    }
                }
                return Fail(error: APIError.unknown)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func post<T: Decodable, U: Encodable>(type: T.Type, url: URL, payload: U) -> AnyPublisher<T, APIError> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "post"
//        headers.forEach { (key, value) in
//            if let value = value as? String {
//                urlRequest.setValue(value, forHTTPHeaderField: key)
//            }
//        }
//
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("a5b39dedacbffd95e1421020dae7c8b5ac3cc", forHTTPHeaderField: "x-apikey")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(payload)
            urlRequest.httpBody = jsonData
        }catch {
            print("\(error.localizedDescription)")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .mapError { _ in .unknown }
            .flatMap { data, response -> AnyPublisher<T, APIError> in
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        return Just(data)
                            .decode(type: T.self, decoder: decoder)
                            .mapError {_ in .decodingError}
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: APIError.httpError(response.statusCode))
                            .eraseToAnyPublisher()
                    }
                }
                return Fail(error: APIError.unknown)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func put<T: Decodable, U: Encodable>(type: T.Type, url: URL, payload: U) -> AnyPublisher<T, APIError> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "put"

        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("a5b39dedacbffd95e1421020dae7c8b5ac3cc", forHTTPHeaderField: "x-apikey")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(payload)
            urlRequest.httpBody = jsonData
        }catch {
            print("\(error.localizedDescription)")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .mapError { _ in .unknown }
            .flatMap { data, response -> AnyPublisher<T, APIError> in
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        return Just(data)
                            .decode(type: T.self, decoder: decoder)
                            .mapError {_ in .decodingError}
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: APIError.httpError(response.statusCode))
                            .eraseToAnyPublisher()
                    }
                }
                return Fail(error: APIError.unknown)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func delete(url: URL) -> AnyPublisher<Bool, APIError> {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "delete"
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.setValue("a5b39dedacbffd95e1421020dae7c8b5ac3cc", forHTTPHeaderField: "x-apikey")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .mapError { _ in .unknown }
            .flatMap { data, response -> AnyPublisher<Bool, APIError> in
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        return Just(true)
                            .mapError {_ in .decodingError}
                            .eraseToAnyPublisher()
                    } else {
                        return Fail(error: APIError.httpError(response.statusCode))
                            .eraseToAnyPublisher()
                    }
                }
                return Fail(error: APIError.unknown)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
