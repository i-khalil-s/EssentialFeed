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
        
        expect(sut, toCompleteWith: .failure(retreivalError), when: {
            store.completeRetreival(with: retreivalError)
        })
        
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        let receivedImages = [FeedImage]()
        
        expect(sut, toCompleteWith: .success(receivedImages), when: { store.completeRetreivalWithEmptyCache() })

    }
    
    func test_load_deliversCachedImagesOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let nonExpiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success(feed.models), when: {
            store.completeRetreival(with: feed.local, timestamp: nonExpiredTimestamp)
            
        })
    }
    
    
    func test_load_deliversNoCachedImagesOnExactlyExpiredCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge()
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetreival(with: feed.local, timestamp: expiredTimestamp)
            
        })
    }
    
    func test_load_deliversNoCachedImagesOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetreival(with: feed.local, timestamp: expiredTimestamp)
            
        })
    }
    
    func test_load_hasNoSideEffectsOnRetreivalError() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in}
        
        store.completeRetreival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in}
        
        store.completeRetreivalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let nonExpiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetreival(with: feed.local, timestamp: nonExpiredTimestamp)
        }
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_load_hasNoSideEffectsOnExperationCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let experationTimestamp = fixCurrentDate.minusFeedCacheMaxAge()
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetreival(with: feed.local, timestamp: experationTimestamp)
        }
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetreival(with: feed.local, timestamp: expiredTimestamp)
        }
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.LoadResult]()
        
        sut?.load { results in
            receivedResults.append(results)
        }
        
        sut = nil
        
        store.completeRetreivalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: ()->Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load command to be executed")

        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
    
}
