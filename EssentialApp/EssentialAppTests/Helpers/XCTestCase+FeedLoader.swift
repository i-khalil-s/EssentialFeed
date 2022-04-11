//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 11/04/22.
//

import XCTest
import Feed

protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, when action: (()-> Void)? = nil, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action?()
        
        wait(for: [exp], timeout: 1.0)
    }

}
