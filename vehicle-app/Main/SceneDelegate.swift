//
//  SceneDelegate.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/13/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }
    
    private func configureWindow() {
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
    }
    
    private func makeRootViewController() -> UIViewController {
        let tabBar = UITabBarController()
        tabBar.viewControllers = [makeListViewController(), makeMapViewController()]
        return tabBar
    }
    
    private func makeListViewController() -> UIViewController {
        let (loader, baseURL) = makeRemoteLoader()
        let viewModel = ListViewModel(loader: MainQueueDispatchDecorator(decoratee: loader), url: baseURL)
        let viewController = UINavigationController(
            rootViewController: ListViewController(
                viewModel: viewModel,
                borderCoorindate: southWeastCoordinate
            )
        )
        viewController.tabBarItem.image = UIImage(systemName: "car.2.fill")
        viewController.tabBarItem.title = "List"
        return viewController
    }
    
    private func makeMapViewController() -> UIViewController {
        let (loader, baseURL) = makeRemoteLoader()
        let viewModel = MapViewModel(loader: MainQueueDispatchDecorator(decoratee: loader), url: baseURL)
        let viewController = UINavigationController(
            rootViewController: MapViewController(viewModel: viewModel)
        )
        viewController.tabBarItem.image = UIImage(systemName: "map.fill")
        viewController.tabBarItem.title = "Map"
        return viewController
    }
    
    private func makeRemoteLoader() -> (RemoteLoader, URL) {
        let loader = RemoteLoader(client: remoteClient)
        let baseURL = VehicleEndpoint.getPoints.url(baseURL: remoteURL, coordinate1: southWeastCoordinate, coordinate2: northEastCoordinate)
        return (loader, baseURL)
    }
}
