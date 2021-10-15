//
//  XCTestCase+FeedStoreSpecs.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 15/10/21.
//

import XCTest
import Feed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWith: .empty, file: file, line: line)
    }
    
    func assertThatRetrievehasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteTwiceWith: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date.init()
        
        insert(cache: (feed, timestamp), into: sut)
        
        expect(sut, toCompleteWith: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date.init()
        
        insert(cache: (feed, timestamp), into: sut)
        
        expect(sut, toCompleteTwiceWith: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, with storeURL: URL, file: StaticString = #filePath, line: UInt = #line) {
        
        try! anyString().write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toCompleteWith: .failure(anyNSError()), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, with storeURL: URL, file: StaticString = #filePath, line: UInt = #line) {
        
        try! anyString().write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toCompleteTwiceWith: .failure(anyNSError()), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let existingCache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        let firstInsertionError = insert(cache: existingCache, into: sut)
        XCTAssertNil(firstInsertionError, "Expected to create cache succesfully", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let existingCache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        insert(cache: existingCache, into: sut)
        
        let lastestCache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        let lastestInsertionError = insert(cache: lastestCache, into: sut)
        XCTAssertNil(lastestInsertionError, "Expected to override cache succesfully", file: file, line: line)
        
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let existingCache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        insert(cache: existingCache, into: sut)
        
        let lastestCache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        insert(cache: lastestCache, into: sut)
        
        expect(sut, toCompleteTwiceWith: .found(feed: lastestCache.feed, timestamp: lastestCache.timestamp), file: file, line: line)
    }
    
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let cache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        let invalidError = insert(cache: cache, into: sut)
        
        XCTAssertNotNil(invalidError, "Expected cache insertion to fail with error", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffecsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let cache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        insert(cache: cache, into: sut)
        
        expect(sut, toCompleteWith: .empty, file: file, line: line)
    }
    
    func assertThatDeleteDeliverNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deleteError = delete(from: sut)
        XCTAssertNil(deleteError, "Expected no failure on deletion of empty cache", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(from: sut)
        
        expect(sut, toCompleteWith: .empty, file: file, line: line)
    }
    
    func assertThatDeleteDeliverNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let cache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        insert(cache: cache, into: sut)
        
        let deleteError = delete(from: sut)
        XCTAssertNil(deleteError, "Expected no failure on deletion of empty cache", file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let cache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        insert(cache: cache, into: sut)
        delete(from: sut)
        
        expect(sut, toCompleteWith: .empty, file: file, line: line)
    }
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let deletionError = delete(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail with error but got nil", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        delete(from: sut)
        
        expect(sut, toCompleteWith: .empty, file: file, line: line)
    }
    
    func assertThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        
        var completedOperations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Run operation 1")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Run operation 2")
        sut.deleteCachedFeed { _ in
            completedOperations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Run operation 3")
        sut.insert(feed: uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperations.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperations, [op1, op2, op3], "Expected operations to run serially but finished in the wrong order", file: file, line: line)
        
    }
    
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
