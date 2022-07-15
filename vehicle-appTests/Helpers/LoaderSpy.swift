//
//  LoaderSpy.swift
//  vehicle-appTests
//
//  Created by Mohammad Bitar on 7/15/22.
//

@testable import vehicle_app
import Foundation

class LoaderSpy: VehicleLoader {
    typealias Result = RemoteLoader.Result
    
    private var completions = [(Result) -> Void]()
    
    var loadCallCount: Int {
        return completions.count
    }
    
    func load(url: URL, completion: @escaping (Result) -> Void) {
        completions.append(completion)
    }
    
    func completeVehicleLoading(with points: [Point] = [], at index: Int = 0) {
        completions[index](.success(points))
    }
    
    func completeVehicleWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        completions[index](.failure(error))
    }
}
