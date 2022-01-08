//
//  FeedViewModel.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 07/01/22.
//

import Foundation
import Feed

final class FeedViewModel {
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.onFeedLoad?(feed)
            }
            self.isLoading = false
        }
    }
}
