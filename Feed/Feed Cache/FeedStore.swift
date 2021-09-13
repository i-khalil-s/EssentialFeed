//
//  FeedStore.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 10/09/21.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalFeedItem : Equatable {
    public let id: UUID
    public let description, location: String?
    public let imageURL: URL
    
    public init (id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
