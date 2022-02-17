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

final class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
        
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedRealod()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedRealod()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a thrid loading request once user initiates another load")
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
    
    func test_feedImageView_loadImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image requests until view is visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected firts image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0, image1].map { $0.url}, "Expected second image URL request once second view becomes also visible")
    }
    
    func test_feedImageView_cancelsImageURLLoadingWhenIsNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.canceledImageURLs, [], "Expected no cancelled image requests until view is visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [image0.url], "Expected one cancelled image URL request once first view is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [image0, image1].map { $0.url}, "Expected two cancelled image URL request once second view is also not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhenImageIsLoading() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expect loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expect loading indicator for second view while loading second image")
        
        loader.compleImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expect no loading indicator for first view when loading first image completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expect loading indicator for second view when first view state changed")
        
        loader.compleImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expect loading indicator for first view when second view state changed")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expect no loading indicator for second view when loading second image completes successfully")
        
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, .none, "Expect no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expect no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.compleImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expect image for first view when loading first image completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expect no image for second view when first view state changed")
        
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.compleImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expect image for first view when second view state changed")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expect image for second view when loading second image completes successfully")
        
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expect no retry action second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.compleImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action for first view when loading first image completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expect no retry action for second view when first view state changed")
        
        loader.compleImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action for first view when second view state changed")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expect retry action for second view when loading second image completes with error")
        
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [makeImage()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expect no retry action for first view while loading first image")
        
        let imageData0 = Data("invalid data".utf8)
        loader.compleImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, true, "Expect retry action for first view when loading first image completes with invalid data")
        
    }
    
    func test_feedImageViewRetryAction_retriesLoad() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(loader.loadedImageURLs, [image0, image1].map {$0.url}, "Expect two image requests from the two visible views")
        
        loader.compleImageLoadingWithError(at: 0)
        loader.compleImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0, image1].map {$0.url}, "Expect only two image requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0, image1, image0].map {$0.url}, "Expect three image requests after first view retry action")
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0, image1, image0, image1].map {$0.url}, "Expect fourth image requests after second view retry action")
        
    }
    
    func test_feedImageView_preloadImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expect no image URL requests until near visible")
        
        sut.simulateNearVisibleImage(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0].map {$0.url}, "Expect first image requests once first image is near visible")
        
        sut.simulateNearVisibleImage(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0, image1].map {$0.url}, "Expect second image requests once second image is near visible")
        
    }
    
    func test_feedImageView_cancelsImageURLWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.canceledImageURLs, [], "Expect no image URL cancelled until near visible")
        
        sut.simulateNotNearVisibleImage(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [image0].map {$0.url}, "Expect first image cancelled once first image is not near visible")
        
        sut.simulateNotNearVisibleImage(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [image0, image1].map {$0.url}, "Expect second image cancelled once second image is not near visible")
        
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.compleFeedLoading(with: [makeImage()])
        
        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.compleImageLoading(with: anyImageData())
        
        XCTAssertNil(view?.renderedImage, "Exected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let expectation = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.compleFeedLoading(at: 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader, imageLoader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://ant-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func anyImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
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
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        // MARK: FeedLoader
        
        private var feedRequests: [(FeedLoader.Result) -> Void] = []
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func compleFeedLoading(with feedModel: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feedModel))
        }
        
        func compleFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK: FeedImageDataLoader
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallBack: () -> Void
            
            func cancel() {
                cancelCallBack()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map {$0.url}
        }
        private(set) var canceledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.canceledImageURLs.append(url)
                
            }
        }
        
        func compleImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func compleImageLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedRealod() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int = 0) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at index: Int = 0) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: index)
        let delegate = tableView.delegate
        
        let indexPath = IndexPath(row: index, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        
        return view
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
    
    func simulateNearVisibleImage(at index: Int = 0) {
        let dataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        dataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateNotNearVisibleImage(at index: Int = 0) {
        simulateNearVisibleImage(at: index)
        
        let dataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
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
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
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

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
