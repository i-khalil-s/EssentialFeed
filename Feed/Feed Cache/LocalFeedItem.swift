//
//  LocalFeedItem.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 13/09/21.
//

import Foundation

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
