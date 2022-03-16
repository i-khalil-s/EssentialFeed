//
//  FeedItem.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 02/06/21.
//

import Foundation

public struct FeedImage : Hashable {
    public let id: UUID
    public let description, location: String?
    public let url: URL
    
    public init (id: UUID, description: String? = nil, location: String? = nil, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
