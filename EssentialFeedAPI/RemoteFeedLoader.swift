//
//  RemoteFeedLoader.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 04/06/21.
//

import Feed

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
