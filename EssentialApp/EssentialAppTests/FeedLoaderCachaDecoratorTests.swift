//
//  FeedLoaderCachaDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 11/04/22.
//

import Foundation
import XCTest
import Feed

final class FeedLoaderCachaDecorator: FeedLoader {
    private var decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

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
    
    // MARK: Helpers:
    private func makeSUT(
        loader result: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoader {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCachaDecorator(decoratee: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
