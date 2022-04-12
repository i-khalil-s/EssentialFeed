//
//  FeedLoaderImageCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 12/04/22.
//

import XCTest
import Feed

final class FeedLoaderImageCacheDecorator: FeedImageDataLoader {
    private var decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedLoaderImageCacheDecoratorTests: XCTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let imageData = anyImageData()
        let loader = FeedImageDataLoaderStub(result: .success(imageData), url: anyURL())
        let sut = FeedLoaderImageCacheDecorator(decoratee: loader)
        
        expect(sut, from: anyURL(), toCompleteWith: .success(imageData))
    }
    
    // MARK: Helpers
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
