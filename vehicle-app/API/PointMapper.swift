//
//  PointMapper.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import Foundation

final class PointMapper {
    private struct List: Decodable {
        private let poiList: [RemotePoint]
    
        private struct RemotePoint: Decodable {
            let id: Int
            let coordinate: RemoteCoordinate
            let state: String
            let type: String
            let heading: Double
        
            struct RemoteCoordinate: Decodable {
                let latitude: Double
                let longitude: Double
            }
        }
        
        var points: [Point] {
            return poiList.map { Point(
                id: $0.id,
                coordinate: Coordinate(
                    latitude: $0.coordinate.latitude,
                    longitude: $0.coordinate.longitude
                ),
                state: $0.state == "ACTIVE" ? .active : .inactive,
                type: $0.type,
                heading: $0.heading
            )
            }
        }
    }
    
    private enum Error: Swift.Error {
        case invalidData
    }
    
    private static var OK_200: Int { 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Point] {
        guard response.statusCode == OK_200, let list = try? JSONDecoder().decode(List.self, from: data) else {
            throw Error.invalidData
        }
        
        return list.points
    }
}
