//
//  CoreLocationHelpers.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import Foundation
import CoreLocation

final class CoreLocationHelpers {
    
    static func calculateDistanceBetween(_ p1: Coordinate, _ p2: Coordinate) -> String {
        let coordinate1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
        let coordinate2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
        
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        let s = String(format: "%.2f", distanceInMeters)
        
        if distanceInMeters <= 1609 {
            return s + " Meters"
        } else {
            return s + " Miles"
        }
    }
}
