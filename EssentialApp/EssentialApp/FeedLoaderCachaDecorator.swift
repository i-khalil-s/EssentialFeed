//
//  FeedLoaderCachaDecorator.swift
//  EssentialApp
//
//  Created by Sergio Khalil Bello Garcia on 12/04/22.
//

import Feed

public final class FeedLoaderCachaDecorator: FeedLoader {
    private var decoratee: FeedLoader
    private var cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load{ [weak self] result in
            completion(result.map{ feed in
                self?.cache.save(feed: feed) { _ in }
                return feed
            })
        }
    }
}
