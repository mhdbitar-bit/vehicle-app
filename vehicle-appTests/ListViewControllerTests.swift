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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let viewModel = ListViewModel(loader: loader)
        let sut = ListViewController(viewModel: viewModel, borderCoorindate: Coordinate(latitude: 53.694865, longitude: 9.757589))
        trackForMemoryLeacks(loader, file: file, line: line)
        trackForMemoryLeacks(sut, file: file, line: line)
        return (sut, loader)
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
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0))
            }
        }
    }
}
