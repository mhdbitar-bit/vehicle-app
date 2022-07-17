//
//  RemoteLoader.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import Foundation

final class RemoteLoader: VehicleLoader {
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(url: URL, completion: @escaping (VehicleLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let (.success((data, response))):
                completion(self.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> VehicleLoader.Result {
        do {
            return .success(try PointMapper.map(data, from: response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
