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
        navigationController.setViewControllers([makeMapViewController()], animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func makeRootViewController() -> ListViewController {
        let (loader, baseURL) = makeRemoteLoader()
        let viewModel = ListViewModel(loader: MainQueueDispatchDecorator(decoratee: loader), url: baseURL)
        let viewController = ListViewController(viewModel: viewModel, borderCoorindate: southWeastCoordinate)
        return viewController
    }
    
    private func makeMapViewController() -> MapViewController {
        let (loader, baseURL) = makeRemoteLoader()
        let viewModel = MapViewModel(loader: MainQueueDispatchDecorator(decoratee: loader), url: baseURL)
        let viewController = MapViewController(viewModel: viewModel)
        return viewController
    }
    
    private func makeRemoteLoader() -> (RemoteLoader, URL) {
        let loader = RemoteLoader(client: remoteClient)
        let baseURL = VehicleEndpoint.getPoints.url(baseURL: remoteURL, coordinate1: southWeastCoordinate, coordinate2: northEastCoordinate)
        return (loader, baseURL)
    }
}

