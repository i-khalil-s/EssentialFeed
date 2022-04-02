//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 30/03/22.
//

import Feed
import XCTest

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryImageDataLoader: FeedImageDataLoader
    private let secondaryImageDataLoader: FeedImageDataLoader
    
    init(primaryImageDataLoader: FeedImageDataLoader, secondaryImageDataLoader: FeedImageDataLoader) {
        self.primaryImageDataLoader = primaryImageDataLoader
        self.secondaryImageDataLoader = secondaryImageDataLoader
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primaryImageDataLoader.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.secondaryImageDataLoader.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_loadsPrimaryImageData() {
        let primaryResult: FeedImageDataLoader.Result = .success(anyImageData())
        let fallbackResult: FeedImageDataLoader.Result = .success(anyImageData(withColor: .blue))
        let primary = FeedImageDataLoaderStub(result: primaryResult, url: anyURL())
        let fallback = FeedImageDataLoaderStub(result: fallbackResult, url: anyURL())
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primaryImageDataLoader: primary,
            secondaryImageDataLoader: fallback
        )
        
        expect(sut, toCompleteWith: primaryResult)    }
    
    func test_load_loadsFallBackOnFailedPrimaryImageData() {
        let fallbackResult: FeedImageDataLoader.Result = .success(anyImageData())
        let primary = FeedImageDataLoaderStub(result: .failure(anyNSError()), url: anyURL())
        let fallback = FeedImageDataLoaderStub(result: fallbackResult, url: anyURL())
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primaryImageDataLoader: primary,
            secondaryImageDataLoader: fallback
        )
        
        expect(sut, toCompleteWith: fallbackResult)
    }
    
    func test_load_deliversFailureOnPrimaryAndFallbackFailure() {
        let primary = FeedImageDataLoaderStub(result: .failure(anyNSError()), url: anyURL())
        let fallback = FeedImageDataLoaderStub(result: .failure(anyNSError()), url: anyURL())
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primaryImageDataLoader: primary,
            secondaryImageDataLoader: fallback
        )
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: Helper
    private func makeSUT(
        primaryResult: FeedImageDataLoader.Result,
        fallBackResult: FeedImageDataLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedImageDataLoader {
        let primaryLoader = FeedImageDataLoaderStub(result: primaryResult, url: anyURL())
        let fallbackLoader = FeedImageDataLoaderStub(result: fallBackResult, url: anyURL())
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primaryImageDataLoader: primaryLoader,
            secondaryImageDataLoader: fallbackLoader
        )
        
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: FeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: (() -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion block")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(let expectedData), .success(let receivedData)):
                XCTAssertEqual(expectedData, receivedData)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action?()
        
        wait(for: [exp], timeout: 0.5)
    }
}

private class FeedImageDataLoaderStub: FeedImageDataLoader {
    private let result: FeedImageDataLoader.Result
    private let url: URL
    
    init(result: Result<Data, Error>, url: URL) {
        self.result = result
        self.url = url
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        completion(result)
        return TaskWrapper()
    }
}