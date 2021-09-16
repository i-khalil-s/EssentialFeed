//
//  LoadFeedFromCacheUseCaseTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 16/09/21.
//

import XCTest
import Feed


class LoadFeedFromCache: XCTestCase {
    
    func test_init_DoesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrival() {
        let (sut, store) = makeSUT()
        
        sut.load() {_ in }
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_load_failsOnRequestCacheRetrival() {
        let (sut, store) = makeSUT()
        let retreivalError = anyNSError()
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for load command to be executed")
        
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected error, got \(result) instead")
            }
            exp.fulfill()
        }
        
        store.completeRetreival(with: retreivalError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError as NSError?, retreivalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        var receivedImages: [FeedImage]?

        let exp = expectation(description: "Wait for load command to be executed")

        sut.load { result in
            switch result {
            case let .success(images):
                receivedImages = images
            default:
                XCTFail("Expected `Images`, got \(result) instead")
            }
            exp.fulfill()
        }

        store.completeRetreivalWithEmptyCache()

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedImages, [])
    }
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    
    private func anyNSError() -> NSError {
        return NSError(domain: "Any error", code: 1)
    }
    
}
