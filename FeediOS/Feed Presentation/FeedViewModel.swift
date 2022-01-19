//
//  FeedViewModel.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 07/01/22.
//

import Feed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.onFeedLoad?(feed)
            }
            self.onLoadingStateChange?(false)
        }
    }
}
