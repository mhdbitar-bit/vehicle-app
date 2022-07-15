//
//  MapViewController.swift
//  vehicle-app
//
//  Created by Mohammad Bitar on 7/14/22.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {
    
    private let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        setupLayout()
    }
    
    private func setupMap() {
        let latitude: CLLocationDegrees = 53.5511
        let longitude: CLLocationDegrees = 9.9937
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        mapView.centerToLocation(initialLocation)
        
        let oahuCenter = CLLocation(latitude: 53.5511, longitude: 9.9937)
        let region = MKCoordinateRegion(
            center: oahuCenter.coordinate,
            latitudinalMeters: 50000,
            longitudinalMeters: 60000
        )
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    private func setupLayout() {
        view.addSubview(mapView)
        
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension MapViewController: MKMapViewDelegate {
    
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        setRegion(coordinateRegion, animated: true)
    }
}
