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
    
    func test_load_deliversCachedImagesOnLessThenSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let lessThanSevenOldDaysTimestamp = fixCurrentDate.adding(days: -7).adding(seconds: 1)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success(feed.models), when: {
            store.completeRetreival(with: feed.local, timestamp: lessThanSevenOldDaysTimestamp)
            
        })
    }
    
    
    func test_load_deliversNoCachedImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let sevenOldDaysTimestamp = fixCurrentDate.adding(days: -7)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetreival(with: feed.local, timestamp: sevenOldDaysTimestamp)
            
        })
    }
    
    func test_load_deliversNoCachedImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixCurrentDate = Date()
        let moreThanSevenOldDaysTimestamp = fixCurrentDate.adding(days: -7).adding(seconds: -1)
        
        let (sut, store) = makeSUT(currentDate: {fixCurrentDate})
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetreival(with: feed.local, timestamp: moreThanSevenOldDaysTimestamp)
            
        })
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

private extension Date {
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
