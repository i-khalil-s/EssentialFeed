//
//  FeedLoaderImageCacheDecorator.swift
//  EssentialApp
//
//  Created by Sergio Khalil Bello Garcia on 13/04/22.
//

import Feed

public final class FeedLoaderImageCacheDecorator: FeedImageDataLoader {
    private var decoratee: FeedImageDataLoader
    private var cache: FeedImageCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            guard let self = self else { return }
            if let data = try? result.get() {
                self.cache.save(data, for: url) { _ in }
            }
            completion(result)
        }
    }
}
