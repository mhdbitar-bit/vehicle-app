@testable import vehicle_app
import XCTest
import MapKit

final class MapViewControllerTests: XCTestCase {

    func test_IsComposedOfMapView() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertNotNil(sut.mapView)
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
