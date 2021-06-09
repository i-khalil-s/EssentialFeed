//
//  FeedItem.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 02/06/21.
//

import Foundation

public struct FeedItem : Equatable {
    let id: UUID
    var description, location: String?
    var imageURL: URL
}
