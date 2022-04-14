//
//  FeedCacheIntegrationTests.swift
//  FeedCacheIntegrationTests
//
//  Created by Sergio Khalil Bello Garcia on 26/10/21.
//

import Feed
import XCTest


/// We test only happy paths since we already tested with mocks the errors in the unit tests
class FeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        expect(sutToPerformSave, toSave: feed)
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeparatedInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        
        let firstFeed = uniqueImageFeed().models
        let secondFeed = uniqueImageFeed().models
        
        expect(sutToPerformFirstSave, toSave: firstFeed)
        
        expect(sutToPerformSecondSave, toSave: secondFeed)
        
        expect(sutToPerformLoad, toLoad: secondFeed)
    }
    
    // MARK: Helper
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
        
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad items: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        
        let expectation = expectation(description: "Waiting for cache to load")
        
        sut.load { result in
            switch result{
            case let .success(images):
                XCTAssertEqual(images, items, "Expected empty images but got \(images)", file: file, line: line)
            case let .failure(error):
                XCTFail("Expected success but got failure \(error)", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    @discardableResult
    private func expect(_ sut: LocalFeedLoader, toSave items: [FeedImage], file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        var receivedError: Error?
        let exp = expectation(description: "Wait for first save to be made")
        
        sut.save(feed: items) { result in
            
            switch result {
            case let .failure(error):
                receivedError = error
                XCTAssertNil(error, "Expected success on first save", file: file, line: line)
            default: break
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
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

    private func testSpecificStoreURL() -> URL {
        return cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
