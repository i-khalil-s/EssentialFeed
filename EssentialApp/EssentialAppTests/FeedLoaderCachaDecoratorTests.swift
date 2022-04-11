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

final class FeedLoaderCachaDecoratorTests: XCTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let loader = FeedLoaderStub(result: .success(feed))
        let sut = FeedLoaderCachaDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let loader = FeedLoaderStub(result: .failure(error))
        let sut = FeedLoaderCachaDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .failure(error))
    }
    
    // MARK: Helpers
    private func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, when action: (()-> Void)? = nil, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action?()
        
        wait(for: [exp], timeout: 1.0)
    }
}
