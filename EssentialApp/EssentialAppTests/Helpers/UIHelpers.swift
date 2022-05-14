//
//  UIHelpers.swift
//  FeediOSTests
//
//  Created by Sergio Khalil Bello Garcia on 14/04/22.
//

import UIKit
import FeediOS

extension ListViewController {
    func simulateUserInitiatedReaload() {
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
}

// MARK: Comments
    
extension ListViewController {
    private var commentsSection: Int {
        return 0
    }
    
    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == .zero ? .zero : tableView.numberOfRows(inSection: commentsSection)
    }
    
    func numberOfRenderedCommentViews() -> Int {
        tableView.numberOfSections == .zero ? .zero : tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedCommentViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}
 
// MARK: Feed

extension ListViewController {
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == .zero ? .zero : tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func simulateTapFeedImage(at index: Int = 0) {
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImageSection)
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
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

extension FeedImageCell {
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

extension ImageCommentCell {
    var userNameText: String? {
        return userNameLabel.text
    }
    
    var messageText: String? {
        return commentLabel.text
    }
    
    var dateText: String? {
        return dateLabel.text
    }
}

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
