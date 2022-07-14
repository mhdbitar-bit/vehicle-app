@testable import vehicle_app
import XCTest

final class PointMapper {
    private struct List: Decodable {
        private let poiList: [RemotePoint]
    
        private struct RemotePoint: Decodable {
            let id: Int
            let coordinate: RemoteCoordinate
            let state: String
            let type: String
            let heading: Float
        
            struct RemoteCoordinate: Decodable {
                let latitude: Float
                let longitude: Float
            }
        }
        
        var points: [Point] {
            return poiList.map { Point(
                id: $0.id,
                coordinate: Coordinate(
                    latitude: $0.coordinate.latitude,
                    longitude: $0.coordinate.longitude
                ),
                state: $0.state == "ACTIVE" ? .active : .inactive,
                type: $0.type,
                heading: $0.heading
            )
            }
        }
    }
    
    private enum Error: Swift.Error {
        case invalidData
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Point] {
        guard response.statusCode == 200, let list = try? JSONDecoder().decode(List.self, from: data) else {
            throw Error.invalidData
        }
        
        return list.points
    }
}

final class RemoteLoader {
    private let url: URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connecitivy
        case invalidData
    }

    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Result<[Point], Error>) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let (.success((data, response))):
                if let points = try? PointMapper.map(data, from: response) {
                    completion(.success(points))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connecitivy))
            }
        }
    }
}

final class RemoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [anyURL()])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [anyURL(), anyURL()])
    }
    
    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connecitivy)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                let json = makeJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let json = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_deliversSuccessWithNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeJson([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversSuccessWithItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let point1 = makePoint(id: 832260383, latitude: 53.55267999516122, longitude: 10.008259937167168, state: .active, type: "TAXI", heading: 60.80968848176092)
        
        let point2 = makePoint(id: -1355393842, latitude: 53.55843397171428, longitude: 10.0072480738163, state: .active, type: "TAXI", heading: 56.70343780517578)
        
        expect(sut, toCompleteWith: .success([point1.model, point2.model])) {
            let json = makeJson([point1.json, point2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteLoader, toCompleteWith expectedResult: Result<[Point], RemoteLoader.Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        waitForExpectations(timeout: 0.1)
    }
    
    private func makePoint(id: Int, latitude: Float, longitude: Float, state: State, type: String, heading: Float) -> (model: Point, json: [String: Any]) {
        
        let point = Point(id: id, coordinate: Coordinate(latitude: latitude, longitude: longitude), state: state, type: type, heading: heading)
        
        let json = [
            "id": id,
            "coordinate": [
                "latitude": latitude,
                "longitude": longitude
            ],
            "state": state == .active ? "ACTIVE": "INACTIVE",
            "type": type,
            "heading": heading
        ] as [String: Any]
        
        return (point, json)
    }
    
    class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
    
    func makeJson(_ points: [[String: Any]]) -> Data {
        let json = ["poiList": points]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
