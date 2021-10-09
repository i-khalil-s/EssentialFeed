//
//  FeedStore.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 10/09/21.
//

import Foundation

public enum RetreiveCacheFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetreivalCompletion = (RetreiveCacheFeedResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to Dispatch to appropiate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to Dispatch to appropiate threads, if needed.
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to Dispatch to appropiate threads, if needed.
    func retreive(completion: @escaping RetreivalCompletion)
}
