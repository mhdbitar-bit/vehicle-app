//
//  Point.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/13/22.
//

import Foundation

enum State: String {
    case active = "ACTIVE"
    case inactive = "INACTIVE"
}

struct Point: Equatable {
    let id: Int
    let coordinate: Coordinate
    let state: State
    let type: String
    let heading: Double
}
