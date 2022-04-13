//
//  FeedLoaderImageCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 12/04/22.
//

import XCTest
import Feed

protocol FeedImageCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

final class FeedLoaderImageCacheDecorator: FeedImageDataLoader {
    private var decoratee: FeedImageDataLoader
    private var cache: FeedImageCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            guard let self = self else { return }
            if let data = try? result.get() {
                self.cache.save(data, for: url) { _ in }
            }
            completion(result)
        }
    }
}

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
    
    private class ImageCacheSpy: FeedImageCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            static func == (lhs: FeedLoaderImageCacheDecoratorTests.ImageCacheSpy.Message, rhs: FeedLoaderImageCacheDecoratorTests.ImageCacheSpy.Message) -> Bool {
                switch (lhs, rhs) {
                case let (.save(data, url, _), .save(dataR, urlR, _)):
                    return data == dataR && url == urlR
                }
            }
            
            case save(data: Data, url: URL, completion: (SaveResult) -> Void)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data: data, url: url, completion: completion))
        }
        
        func complete(at index: Int = 0) {
            switch messages[index] {
            case let .save(_, _, completion):
                completion(.success(()))
            }
        }
    }
}
