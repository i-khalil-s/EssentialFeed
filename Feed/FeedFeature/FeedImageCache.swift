//
//  FeedImageCache.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 13/04/22.
//

import Foundation

public protocol FeedImageCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
