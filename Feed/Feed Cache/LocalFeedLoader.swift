//
//  LocalFeedLoader.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 10/09/21.
//

import Foundation

private final class FeedCachePolicy {
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init(){}
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    public static func isValid(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}

public final class LocalFeedLoader {
    
    private let currentDate: () -> Date
    private let store: FeedStore
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
    
}
extension LocalFeedLoader {
    
    public func validateCache() {
        store.retreive { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .failure(_):
                self.store.deleteCachedFeed { _ in }
                
            case let .found(_, timestamp) where !FeedCachePolicy.isValid(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
                
            case .found, .empty: break
            }
        }
    }
    
}

extension LocalFeedLoader {
    
    public typealias SavedResult = Error?
    
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
    
    private func cache(feed: [FeedImage], with completion: @escaping (SavedResult) -> Void) {
        store.insert(feed: feed.toLocalRepresentation(), timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else {return}
            completion(error)
        })
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = LoadFeedResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retreive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timestamp) where FeedCachePolicy.isValid(timestamp, against: self.currentDate()):
                completion(.success(feed.toModels()))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    
}

private extension Array where Element == FeedImage {
    func toLocalRepresentation() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    }
}
