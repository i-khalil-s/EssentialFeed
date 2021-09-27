//
//  CodableFeedStoreTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 27/09/21.
//

import XCTest
import Feed

class CodableFeedStore {
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: decoded.feed, timestamp: decoded.timestamp))
    }
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTest: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override class func tearDown() {
        super.tearDown()
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
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
        let sut = CodableFeedStore()
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
        let sut = CodableFeedStore()
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
}
