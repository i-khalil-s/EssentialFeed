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
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: decoded.localFeed, timestamp: decoded.timestamp))
    }
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableImageFeed.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
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
        let exp = expectation(description: "Wait for cache retrieval to complete")
        
        sut.retreive { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp1 = expectation(description: "Wait for cache retrieval to complete")
        
        sut.retreive { firstResult in
            sut.retreive { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected receiving twice from empty cache to deliver same empty result, but got \(firstResult) and \(secondResult) instead")
                }
                exp1.fulfill()
            }
        }
        
        wait(for: [exp1], timeout: 1.0)
        
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval to complete")
        let feed = uniqueImageFeed().local
        let timestamp = Date.init()
        
        sut.insert(feed: feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed got \(insertionError!) instead")
            
            sut.retreive { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedModels, retrievedTimestamp):
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    XCTAssertEqual(retrievedModels, feed)
                default:
                    XCTFail("Expected found result with \(feed) and \(timestamp.description), but got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
            
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(using: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
