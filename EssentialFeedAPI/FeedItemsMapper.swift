//
//  FeedItemsMapper.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 11/06/21.
//

import Foundation
import Feed

public final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
        
        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)}
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private static var OK_200: Int { return 200}
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws  -> [FeedImage] {
        
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        
        return root.images
    }
}
