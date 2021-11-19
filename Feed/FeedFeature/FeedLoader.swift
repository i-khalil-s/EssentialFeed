//
//  FeedLoader.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 02/06/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
