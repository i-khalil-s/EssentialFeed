//
//  FeedCache.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 12/04/22.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    func save(feed: [FeedImage], completion: @escaping (Result) -> Void)
}

public extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed: feed) { _ in }
    }
}
