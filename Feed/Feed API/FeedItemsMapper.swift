//
//  FeedItemsMapper.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 11/06/21.
//

import Foundation

internal struct RemoteFeedItem : Decodable {
    let id: UUID
    let description, location: String?
    let image: URL
    
    var feedItem : FeedItem {
        return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}

internal final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
        
    }
    
    private static var OK_200: Int { return 200}
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws  -> [RemoteFeedItem] {
        
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
