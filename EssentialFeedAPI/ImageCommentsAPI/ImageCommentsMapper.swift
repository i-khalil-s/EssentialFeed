//
//  ImageCommentsMapper.swift
//  EssentialFeedAPI
//
//  Created by Sergio Khalil Bello Garcia on 23/04/22.
//

import Foundation
import Feed

final class ImageCommentsMapper {
    
    private struct Root: Decodable {
        private let items: [Item]
        
        private struct Item : Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        
        private struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map {
                ImageComment(
                    id: $0.id,
                    message: $0.message,
                    createdAt: $0.created_at,
                    userName: $0.author.username
                )
                
            }
        }
    }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws  -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOK(response: response), let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.comments
    }
    
    private static func isOK(response: HTTPURLResponse) ->  Bool {
        (200...299).contains(response.statusCode)
    }
}
