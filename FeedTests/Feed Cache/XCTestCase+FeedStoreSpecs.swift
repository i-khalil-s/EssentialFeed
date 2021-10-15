//
//  XCTestCase+FeedStoreSpecs.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 15/10/21.
//

import XCTest
import Feed

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert(cache: (feed: [LocalFeedImage], timestamp: Date), into sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        
        sut.insert(feed: cache.feed, timestamp: cache.timestamp) { receivedError in
            insertionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return insertionError
    }
    
    @discardableResult
    func delete(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10)

        return deletionError
    }
    
    func expect(_ sut: FeedStore, toCompleteTwiceWith expectedResult: RetreiveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toCompleteWith expectedResult: RetreiveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieve command to be executed")

        sut.retreive { retrieveResult in
            switch (expectedResult, retrieveResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp)
                XCTAssertEqual(expectedFeed, retrievedFeed)
            default:
                XCTFail("Expected to retreive \(expectedResult), but got \(retrieveResult) instead")
            }
            
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
}
