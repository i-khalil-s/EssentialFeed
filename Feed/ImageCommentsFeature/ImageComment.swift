//
//  ImageComment.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 23/04/22.
//

import Foundation

public struct ImageComment : Hashable {
    public let id: UUID
    public let message, userName: String
    public let createdAt: Date
    
    public init (id: UUID, message: String, createdAt: Date, userName: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.userName = userName
    }
}
