//
//  Shared.swift
//  vehicle-appTests
//
//  Created by Mohammad Bitar on 7/13/22.
//

@testable import vehicle_app
import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func nonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func makePoint(id: Int, latitude: Double, longitude: Double, state: State, type: String, heading: Double) -> (model: Point, json: [String: Any]) {
    
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

func makeJson(_ points: [[String: Any]]) -> Data {
    let json = ["poiList": points]
    return try! JSONSerialization.data(withJSONObject: json)
}
