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
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed successfully")
        
        sut.simulateUserInitiatedFeedRealod()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a load")
    
        sut.simulateUserInitiatedFeedRealod()
        loader.compleFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is not completed")
    }
    
    func test_loadFeedCompletion_renderSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "A description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "Another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.compleFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedRealod()
        loader.compleFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
        
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [image0], at: 0)
        
        sut.simulateUserInitiatedFeedRealod()
        loader.compleFeedLoadingWithError(at: 1)
        
        assertThat(sut, isRendering: [image0])
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://ant-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, but got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image at \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected `locationText` to be \(String(describing: image.location)) for image at \(index)", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected `isShowingLocation` to be \(String(describing: image.description)) for image at \(index)", file: file, line: line)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            return XCTFail("Expected \(feed.count) images count, but got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    
    class LoaderSpy: FeedLoader {
        private var completions: [(FeedLoader.Result) -> Void] = []
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func compleFeedLoading(with feedModel: [FeedImage] = [], at index: Int = 0) {
            completions[index](.success(feedModel))
        }
        
        func compleFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
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
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection: Int {
        return 0
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
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
