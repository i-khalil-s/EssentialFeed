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
    
    public func save(items: [FeedItem], completion: @escaping (SavedResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            
            guard let self = self else {return}
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, with: completion)
                
            }
        }
    }
    
    private func cache(items: [FeedItem], with completion: @escaping (SavedResult) -> Void) {
        store.insert(items: items.toLocalRepresentation(), timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else {return}
            completion(error)
        })
    }
}

private extension Array where Element == FeedItem {
    func toLocalRepresentation() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}
