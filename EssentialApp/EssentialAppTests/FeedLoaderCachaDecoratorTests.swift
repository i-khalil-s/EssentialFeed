//
//  FeedLoaderCachaDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 11/04/22.
//

import Foundation
import XCTest
import Feed
import EssentialApp

final class FeedLoaderCachaDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loader: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let sut = makeSUT(loader: .failure(error))
        
        expect(sut, toCompleteWith: .failure(error))
    }
    
    func test_load_cachesFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loader: .success(feed), cache: cache)
        
        sut.load { _ in }
        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache on success")
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loader: .failure(anyNSError()), cache: cache)
        
        sut.load { _ in }
        XCTAssertTrue(cache.messages.isEmpty, "Expected to NOT cache on failure")
    }
    
    // MARK: Helpers:
    private func makeSUT(
        loader result: FeedLoader.Result,
        cache: CacheSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoader {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCachaDecorator(decoratee: loader, cache: cache)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class CacheSpy: FeedCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        func save(feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}