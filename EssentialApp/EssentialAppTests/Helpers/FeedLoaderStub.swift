//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 11/04/22.
//

import Feed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: Result<[FeedImage], Error>) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
