//
//  FeedImageDataLoaderStub.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 12/04/22.
//

import Feed

class FeedImageDataLoaderStub: FeedImageDataLoader {
    private let result: FeedImageDataLoader.Result
    private let url: URL
    
    init(result: Result<Data, Error>, url: URL) {
        self.result = result
        self.url = url
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        completion(result)
        return TaskWrapper()
    }
}
