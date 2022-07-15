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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: MapViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewModel = MapViewModel(loader: MainQueueDispatchDecorator(decoratee: loader), url: anyURL())
        let sut = MapViewController(viewModel: viewModel)
        trackForMemoryLeacks(loader, file: file, line: line)
        trackForMemoryLeacks(sut, file: file, line: line)
        return (sut, loader)
    }
}
