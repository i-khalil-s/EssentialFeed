//
//  ImageCommentsMapper.swift
//  EssentialFeedAPI
//
//  Created by Sergio Khalil Bello Garcia on 23/04/22.
//

import Foundation

final class ImageCommentsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
        
    }
    
    private static var OK_200: Int { return 200}
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws  -> [RemoteFeedItem] {
        
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
}
