@testable import vehicle_app
import XCTest
import MapKit

final class MapViewControllerTests: XCTestCase {
    
    func test_IsComposedOfMapView() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertNotNil(sut.mapView)
    }
    
    func test_conformsToMKMapViewDelegate() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.conforms(to: MKMapViewDelegate.self), "Expected to confirm MKMapViewDelegate")
    }
    
    func test_AddsAnnotationsToMapView() {
        let point1 = makePoint(id: 10, latitude: 3.552315291358475, longitude: 10.011982172727585, state: .inactive, type: "TAXI", heading: 500)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
    
        loader.completeVehicleLoading(with: [point1.model], at: 0)
        
        let annotationsOnMap = sut.mapView.annotations
        XCTAssertEqual(annotationsOnMap.count, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: MapViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewModel = MapViewModel(loader: MainQueueDispatchDecorator(decoratee: loader), url: anyURL())
        let sut = MapViewController(viewModel: viewModel)
        trackForMemoryLecks(loader, file: file, line: line)
        trackForMemoryLecks(sut, file: file, line: line)
        return (sut, loader)
    }
}
