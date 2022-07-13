//
//  URLSessionHTTPClient.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/13/22.
//

import Foundation

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    private struct UnexpectedValuesRepresentation: Error {}

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
