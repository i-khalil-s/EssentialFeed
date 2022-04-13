//
//  FeedLoaderImageCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 12/04/22.
//

import XCTest
import Feed
import EssentialApp

final class FeedLoaderImageCacheDecoratorTests: XCTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let imageData = anyImageData()
        let loader = FeedImageDataLoaderStub(result: .success(imageData), url: anyURL())
        let (sut, _) = makeSUT(loader: loader)
        
        expect(sut, from: anyURL(), toCompleteWith: .success(imageData))
    }
    
    
    func test_load_failsLoaderFailure() {
        let anyError = anyNSError()
        let loader = FeedImageDataLoaderStub(result: .failure(anyError), url: anyURL())
        let (sut, _) = makeSUT(loader: loader)
        
        expect(sut, from: anyURL(), toCompleteWith: .failure(anyError))
    }
    
    func test_load_cachesImageDateOnSuccess() {
        let imageData = anyImageData()
        let loader = FeedImageDataLoaderStub(result: .success(imageData), url: anyURL())
        let (sut, cache) = makeSUT(loader: loader)
        
        expect(sut, from: anyURL(), toCompleteWith: .success(imageData))
        
        XCTAssertTrue(!cache.messages.isEmpty)
    }
    
    func test_load_doesNotCachesImageDateOnFailure() {
        let anyError = anyNSError()
        let loader = FeedImageDataLoaderStub(result: .failure(anyError), url: anyURL())
        let (sut, cache) = makeSUT(loader: loader)
        
        expect(sut, from: anyURL(), toCompleteWith: .failure(anyError))
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    // MARK: Helpers
    private func makeSUT(loader: FeedImageDataLoader, file: StaticString = #file, line: UInt = #line) -> (FeedLoaderImageCacheDecorator, ImageCacheSpy) {
        let cache = ImageCacheSpy()
        let sut = FeedLoaderImageCacheDecorator(decoratee: loader, cache: cache)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(cache)
        
        return (sut, cache)
    }
    
    private func expect(_ sut: FeedLoaderImageCacheDecorator, from url: URL, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: (() -> Void)? = nil, file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "Wait for image to load")
        
        _ = sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(feed), .success(expectedFeed)):
                XCTAssertEqual(feed, expectedFeed)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult) but got \(result) instead")
            }
            expectation.fulfill()
        }
        
        action?()
        
        wait(for: [expectation], timeout: 0.5)
    }
}
