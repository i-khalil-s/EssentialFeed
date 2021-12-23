//
//  FeedViewControllerTest.swift
//  FeediOSTests
//
//  Created by Sergio Khalil Bello Garcia on 21/12/21.
//

import UIKit
import XCTest
import Feed
import FeediOS

final class FeedViewControllerTest: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedRealod()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedRealod()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a thrid loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingTheFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
    
        loader.compleFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedFeedRealod()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a load")
    
        sut.simulateUserInitiatedFeedRealod()
        loader.compleFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions: [(FeedLoader.Result) -> Void] = []
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func compleFeedLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedRealod() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing ?? false
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
