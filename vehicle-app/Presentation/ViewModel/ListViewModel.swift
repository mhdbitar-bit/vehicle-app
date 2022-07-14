//
//  ListViewModel.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import Foundation
import Combine

final class ListViewModel {
    let title = "Vehicles"
    @Published var points: [Point] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    let loader: RemoteLoader
    
    init(loader: RemoteLoader) {
        self.loader = loader
    }
    
    func loadPoints() {
        isLoading = true
        
        loader.load { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case let .success(points):
                self.points = points
                
            case let .failure(error):
                self.error = error.localizedDescription
            }
        }
    }
    
}
