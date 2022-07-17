//
//  MapViewController.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import UIKit
import MapKit
import Combine

final class Vehicle: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
}

final class MapViewController: UIViewController, Alertable {
    
    private var viewModel: MapViewModel!
    
    private var cancelable: Set<AnyCancellable> = []
    private var vehicles: [Vehicle] = [] {
        didSet {
            self.mapView.addAnnotations(vehicles)
        }
    }
    
    
    let mapView = MKMapView()
    
    convenience init(viewModel: MapViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.title
        mapView.delegate = self
        setupMap()
        setupLayout()
        bind()
    }
    
    private func setupMap() {
        let latitude: CLLocationDegrees = southWestCoordinate.latitude
        let longitude: CLLocationDegrees = southWestCoordinate.longitude
        
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        mapView.centerToLocation(initialLocation)
                
        loadVehicles()
    }
    
    private func setupLayout() {
        view.addSubview(mapView)
        
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func loadVehicles() {
        viewModel.loadPoints()
    }
    
    private func bind() {
        bindError()
        bindItems()
    }
    
    private func bindItems() {
        viewModel.$vehicles.sink { [weak self] vehicles in
            guard let self = self else { return }
            self.vehicles = vehicles
        }.store(in: &cancelable)
    }
    
    private func bindError() {
        viewModel.$error.sink { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(message: error)
            }
        }.store(in: &cancelable)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let mapRect = mapView.visibleMapRect
        let northEastCoordinate = getCoordinateFromMapRectanglePoint(x: mapRect.maxX, y: mapRect.origin.y)
        let southWestCoordinate = getCoordinateFromMapRectanglePoint(x: mapRect.origin.x, y: mapRect.maxY)
        viewModel.loadPoints(northEast: northEastCoordinate, southWest: southWestCoordinate)
    }
    
    private func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> Coordinate {
        let mapPoint = MKMapPoint(x: x, y: y)
        return Coordinate(latitude: mapPoint.coordinate.latitude, longitude: mapPoint.coordinate.longitude)
    }
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 20000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        setRegion(coordinateRegion, animated: true)
    }
}
