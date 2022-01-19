//
//  FeedPresenter.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 13/01/22.
//

import Feed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.feedView?.display(feed: feed)
            }
            self.loadingView?.display(isLoading: false)
        }
    }
}
