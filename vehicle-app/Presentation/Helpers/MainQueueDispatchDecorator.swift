//
//  MainQueueDispatchDecorator.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import Foundation

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        if Thread.isMainThread {
            completion()
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

extension MainQueueDispatchDecorator: VehicleLoader where T == VehicleLoader {
    func load(completion: @escaping (VehicleLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
