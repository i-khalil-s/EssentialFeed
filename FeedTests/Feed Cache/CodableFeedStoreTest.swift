//
//  CodableFeedStoreTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 27/09/21.
//

import XCTest
import Feed

class CodableFeedStore {
    
    private let storeURL: URL
    
    init(using storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct Cache: Codable {
        let feed: [CodableImageFeed]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct CodableImageFeed: Codable {
        private let id: UUID
        private let description, location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: self.id, description: self.description, location: self.location, url: self.url)
        }
    }
    
    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: decoded.localFeed, timestamp: decoded.timestamp))
        } catch {
            completion(.failure(error))
        }
        
        
    }
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map(CodableImageFeed.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func delete(completion: @escaping FeedStore.DeletionCompletion) {
        try? FileManager.default.removeItem(at: storeURL)
        completion(nil)
    }
    
}

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
        var deleteError: Error?
        
        sut.delete { receivedError in
            deleteError = receivedError
        }
        
        expect(sut, toCompleteWith: .empty)
        XCTAssertNil(deleteError, "Expected no failure on deletion of empty cache")
    }
    
    // MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(using: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(cache: (feed: [LocalFeedImage], timestamp: Date), into sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
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
    
    private func expect(_ sut: CodableFeedStore, toCompleteTwiceWith expectedResult: RetreiveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
        expect(sut, toCompleteWith: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toCompleteWith expectedResult: RetreiveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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
