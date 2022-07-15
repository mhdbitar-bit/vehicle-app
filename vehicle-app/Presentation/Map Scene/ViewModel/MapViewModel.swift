//
//  MapViewModel.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/15/22.
//

import Foundation
import MapKit
import Combine

final class MapViewModel {
    let title = "Map"
    @Published var vehicles: [Vehicle] = []
    @Published var error: String? = nil
    
    private let loader: VehicleLoader
    private let url: URL
    
    init(loader: VehicleLoader, url: URL) {
        self.loader = loader
        self.url = url
    }
    
    func loadPoints(northEast: Coordinate? = nil, southWeast: Coordinate? = nil) {
        var pointsUrl = url
        if let northEast = northEast, let southWeast = southWeast {
            pointsUrl = VehicleEndpoint.getPoints.url(baseURL: remoteURL, coordinate1: southWeast, coordinate2: northEast)
        }
        
        loader.load(url: pointsUrl) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(points):
                print(points)
                points.forEach { self.vehicles.append(Vehicle(
                    title: $0.type,
                    coordinate: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                    ))
                }                
            case let .failure(error):
                self.error = error.localizedDescription
            }
        }
    }
    
}
