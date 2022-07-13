@testable import vehicle_app
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (Result) -> Void) {
        completion(.failure(NSError(domain: "any", code: 0)))
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
        }
        
        makeSUT().get(from: url) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        
        let url = anyURL()
        let requestError = anyNSError()
        
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.stub(data: nil, response: nil, error: requestError)
        
        var receivedResult: URLSessionHTTPClient.Result!
        
        makeSUT().get(from: url) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        XCTAssertNotNil(receivedResult)
        
        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> URLSessionHTTPClient {
        return URLSessionHTTPClient()
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
