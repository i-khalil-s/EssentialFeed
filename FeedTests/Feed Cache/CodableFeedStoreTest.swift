//
//  CodableFeedStoreTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 27/09/21.
//

import XCTest
import Feed

class CodableFeedStoreTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toCompleteTwiceWith: .empty)
        
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date.init()
        
        insert(cache: (feed, timestamp), into: sut)
        
        expect(sut, toCompleteWith: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasaNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date.init()
        
        insert(cache: (feed, timestamp), into: sut)
        
        expect(sut, toCompleteTwiceWith: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! anyString().write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! anyString().write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toCompleteTwiceWith: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let existingCache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        let firstInsertionError = insert(cache: existingCache, into: sut)
        XCTAssertNil(firstInsertionError, "Expected to create cache succesfully")
        
        let lastestCache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        let lastestInsertionError = insert(cache: lastestCache, into: sut)
        XCTAssertNil(lastestInsertionError, "Expected to override cache succesfully")
        
        expect(sut, toCompleteTwiceWith: .found(feed: lastestCache.feed, timestamp: lastestCache.timestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidURL)
        let cache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        let invalidError = insert(cache: cache, into: sut)
        
        XCTAssertNotNil(invalidError, "Expected cache insertion to fail with error")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deleteError = delete(from: sut)
        
        XCTAssertNil(deleteError, "Expected no failure on deletion of empty cache")
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_delete_deletesCacheOnNonEmptyCache() {
        let sut = makeSUT()
        let cache = (feed: uniqueImageFeed().local, timestamp: Date.init())
        
        
        insert(cache: cache, into: sut)
        
        let deleteError = delete(from: sut)
        
        XCTAssertNil(deleteError, "Expected no failure on deletion of empty cache")
        expect(sut, toCompleteWith: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noPermissionsURL = cachesDirectory()
        let sut = makeSUT(storeURL: noPermissionsURL)
        
        let deletionError = delete(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail with error")
    }
    
    // MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(using: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(cache: (feed: [LocalFeedImage], timestamp: Date), into sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        
        sut.insert(feed: cache.feed, timestamp: cache.timestamp) { receivedError in
            if let error = receivedError {
                insertionError = error
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return insertionError
    }
    
    @discardableResult
    private func delete(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        
        sut.deleteCachedFeed { receivedError in
            if let error = receivedError {
                deletionError = error
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return deletionError
    }
    
    private func expect(_ sut: FeedStore, toCompleteTwiceWith expectedResult: RetreiveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore, toCompleteWith expectedResult: RetreiveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieve command to be executed")

        sut.retreive { retrieveResult in
            switch (expectedResult, retrieveResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedFound), .found(resultFound)):
                XCTAssertEqual(expectedFound.timestamp, resultFound.timestamp)
                XCTAssertEqual(expectedFound.feed, resultFound.feed)
            default:
                XCTFail("Expected to retreive \(expectedResult), but got \(retrieveResult) instead")
            }
            
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
        
    }

     private func cachesDirectory() -> URL {
         return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
     }
    
    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
