//
//  SceneDelegate.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/13/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let navigationController = UINavigationController()
    let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }
    
    private func configureWindow() {
        navigationController.setViewControllers([makeRootViewController()], animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func makeRootViewController() -> ListViewController {
        let coordinate1 = Coordinate(latitude: 53.694865, longitude: 9.757589)
        let coordinate2 = Coordinate(latitude: 53.394655, longitude: 10.099891)
        let remoteURL = URL(string: "https://api.mytaxi.com/poiservice/poi/v1")!
        
        let baseURL = VehicleEndpoint.getPoints.url(baseURL: remoteURL, coordinate1: coordinate1, coordinate2: coordinate2)
        let loader = RemoteLoader(url: baseURL, client: remoteClient)
        let viewModel = ListViewModel(loader: MainQueueDispatchDecorator(decoratee: loader))
        let viewController = ListViewController(viewModel: viewModel, borderCoorindate: coordinate1)
        return viewController
    }
}

