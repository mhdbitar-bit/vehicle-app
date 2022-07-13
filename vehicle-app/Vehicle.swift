//
//  Vehicle.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/13/22.
//

import Foundation

enum State: String {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

struct Vehicle {
    let id: Int
    let coordinate: Coordinate
    let state: State
    let type: String
    let heading: Float
}

struct Coordinate {
    let latitude: Float
    let longitude: Float
}
