//
//  ValidateFeedCacheUseCase.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 24/09/21.
//

import XCTest
import Feed

class ValidateFeedCacheUseCase: XCTestCase {
    
    func test_init_DoesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetreivalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetreival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetreivalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_validate_doesNotDeleteCacheOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let nonExpiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        sut.validateCache()
        store.completeRetreival(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    func test_validate_deletesCacheOnExpirationCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let experationTimestamp = fixCurrentDate.minusFeedCacheMaxAge()
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        sut.validateCache()
        store.completeRetreival(with: feed.local, timestamp: experationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validate_deletesCacheOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let expiredTimestamp = fixCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        sut.validateCache()
        store.completeRetreival(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validate_doesNotDeletesCacheAfterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store,currentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        store.completeRetreival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
}
