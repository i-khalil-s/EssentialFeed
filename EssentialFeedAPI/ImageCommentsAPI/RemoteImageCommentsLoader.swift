//
//  RemoteImageCommentsLoader.swift
//  EssentialFeedAPI
//
//  Created by Sergio Khalil Bello Garcia on 23/04/22.
//

import Feed

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
