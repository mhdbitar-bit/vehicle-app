//
//  VehicleEndpoint.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import Foundation

enum VehicleEndpoint {
    case getPoints
    
    func url(baseURL: URL, coordinate1: Coordinate, coordinate2: Coordinate) -> URL {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = baseURL.path
        components.queryItems = [
            URLQueryItem(name: "p2Lat", value: "\(coordinate2.latitude)"),
            URLQueryItem(name: "p1Lon", value: "\(coordinate1.longitude)"),
            URLQueryItem(name: "p1Lat", value: "\(coordinate1.latitude)"),
            URLQueryItem(name: "p2Lon", value: "\(coordinate2.longitude)")
        ]
        return components.url!
    }
}
