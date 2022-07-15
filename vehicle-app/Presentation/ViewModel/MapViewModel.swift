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
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    let loader: VehicleLoader
    
    init(loader: VehicleLoader) {
        self.loader = loader
    }
    
    func loadPoints() {
        isLoading = true
        
        loader.load { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case let .success(points):
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
