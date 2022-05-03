//
//  FeedPresenter.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 17/03/22.
//

import Foundation

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let errorView: ResourceErrorView
    private let loadingView: ResourceLoadingView
    
    public init(feedView: FeedView, errorView: ResourceErrorView, loadingView: ResourceLoadingView) {
        self.feedView = feedView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    public static var title: String {
        return NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the Feed View"
        )
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(Self.map(feed))
        loadingView.display(.init(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(.init(isLoading: false))
    }
    
    private var feedLoadError: String {
        return NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed wwhen we cannot display image from server"
        )
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
