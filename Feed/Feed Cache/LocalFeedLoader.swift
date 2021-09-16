//
//  LocalFeedLoader.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 10/09/21.
//

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SavedResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(feed: [FeedImage], completion: @escaping (SavedResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            
            guard let self = self else {return}
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed: feed, with: completion)
                
            }
        }
    }
    
    public func load(completion: @escaping (SavedResult) -> Void) {
        store.retreive(completion: completion)
    }
    
    private func cache(feed: [FeedImage], with completion: @escaping (SavedResult) -> Void) {
        store.insert(feed: feed.toLocalRepresentation(), timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else {return}
            completion(error)
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocalRepresentation() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
