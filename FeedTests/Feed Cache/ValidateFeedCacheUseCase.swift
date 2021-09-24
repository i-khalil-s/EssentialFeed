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
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
}
