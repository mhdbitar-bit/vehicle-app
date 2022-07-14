//
//  XCTestCase+MemoryLeackTrackingHelper.swift
//  vehicle-appTests
//
//  Created by Mohammad Bitar on 7/14/22.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeacks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
