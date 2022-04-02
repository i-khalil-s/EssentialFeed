//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Sergio Khalil Bello Garcia on 01/04/22.
//

import Feed

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primaryImageDataLoader: FeedImageDataLoader
    private let secondaryImageDataLoader: FeedImageDataLoader
    
    public init(primaryImageDataLoader: FeedImageDataLoader, secondaryImageDataLoader: FeedImageDataLoader) {
        self.primaryImageDataLoader = primaryImageDataLoader
        self.secondaryImageDataLoader = secondaryImageDataLoader
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primaryImageDataLoader.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.secondaryImageDataLoader.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
}
