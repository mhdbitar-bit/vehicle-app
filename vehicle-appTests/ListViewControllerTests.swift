@testable import vehicle_app
import XCTest

final class ListViewControllerTests: XCTestCase {
    
    func test_loadItemsActions_requestItemsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedResourceReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedResourceReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadItemsActions_isVisibleWhileLoadingItems() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeVehicleLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfuly")

        sut.simulateUserInitiatedResourceReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeVehicleWithError(at: 1)
                XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadItemsCompletion_rendersSuccessfullyloadedItems() {
        let point1 = makePoint(id: 10, latitude: 3.552315291358475, longitude: 10.011982172727585, state: .inactive, type: "TAXI", heading: 500)
        
        let point2 = makePoint(id: 100, latitude: 53.544433455545985, longitude: 9.98176272958517, state: .inactive, type: "TAXI", heading: 300)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeVehicleLoading(with: [point1.model], at: 0)
        assertThat(sut, isRendering: [point1.model])
        
        sut.simulateUserInitiatedResourceReload()
        loader.completeVehicleLoading(with: [point1.model, point2.model], at: 1)
        assertThat(sut, isRendering: [point1.model, point2.model])
    }
    
    func test_loadItemsCompletion_doesNotAlertCurrentRenderingStateOnError() {
        let point1 = makePoint(id: 10, latitude: 3.552315291358475, longitude: 10.011982172727585, state: .inactive, type: "TAXI", heading: 500)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeVehicleLoading(with: [point1.model], at: 0)
        assertThat(sut, isRendering: [point1.model])
        
        sut.simulateUserInitiatedResourceReload()
        loader.completeVehicleWithError(at: 1)
        assertThat(sut, isRendering: [point1.model])
    }
    
    func test_loadItemsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeVehicleLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewModel = ListViewModel(loader: loader)
        let sut = ListViewController(viewModel: viewModel, borderCoorindate: Coordinate(latitude: 53.694865, longitude: 9.757589))
        trackForMemoryLeacks(loader, file: file, line: line)
        trackForMemoryLeacks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ListViewController, isRendering points: [Point], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedResourceViews() == points.count else {
            return XCTFail("Expected \(points.count) items, got \(sut.numberOfRenderedResourceViews()) instead", file: file, line: line)
        }
        
        points.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: ListViewController, hasViewConfiguredFor point: Point, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.view(at: index) as? VehicleTableViewCell
        
        guard let cell = view else {
            return XCTFail("Expected \(UITableViewCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.vehicleTypeLabel.text, point.type, "Expected title to be \(String(describing: point.type)) for vehicle view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.latitudeLabel.text, "\(point.coordinate.latitude)", "Expected latitude to be \(String(describing: point.coordinate.latitude)) for vehicle latitude view at index \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.longitudeLabel.text, "\(point.coordinate.longitude)", "Expected longitude to be \(String(describing: point.coordinate.longitude)) for vehicle longitude view at index \(index)", file: file, line: line)
        
        let distance = CoreLocationHelpers.calculateDistanceBetween(Coordinate(latitude: 53.694865, longitude: 9.757589), point.coordinate)
        
        XCTAssertEqual(cell.distanceLabel.text, distance, "Expected distance to be \(distance) for vehicle distance view at index \(index)", file: file, line: line)
    }
    
    private class LoaderSpy: VehicleLoader {
        typealias Result = RemoteLoader.Result
        
        private var completions = [(Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (Result) -> Void) {
            completions.append(completion)
        }
        
        func completeVehicleLoading(with points: [Point] = [], at index: Int = 0) {
            completions[index](.success(points))
        }
        
        func completeVehicleWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
        }
    }
}

private extension UITableViewController {
    
    func simulateUserInitiatedResourceReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedResourceViews() -> Int {
        return tableView.numberOfRows(inSection: resourceSection)
    }
    
    private var resourceSection: Int {
        return 0
    }
    
    func view(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: resourceSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0))
            }
        }
    }
}
