//
//  FeedLoader.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 02/06/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
