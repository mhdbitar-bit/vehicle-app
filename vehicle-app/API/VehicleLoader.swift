//
//  VehicleLoader.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import Foundation

protocol VehicleLoader {
    typealias Result = Swift.Result<[Point], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
