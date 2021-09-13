//
//  LocalFeedItem.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 13/09/21.
//

import Foundation

public struct LocalFeedImage : Equatable {
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
