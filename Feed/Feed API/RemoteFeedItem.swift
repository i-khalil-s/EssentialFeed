//
//  RemoteFeedItem.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 13/09/21.
//

import Foundation

internal struct RemoteFeedItem : Decodable {
    let id: UUID
    let description, location: String?
    let image: URL
    
    var feedItem : FeedImage {
        return FeedImage(id: id, description: description, location: location, url: image)
    }
}
