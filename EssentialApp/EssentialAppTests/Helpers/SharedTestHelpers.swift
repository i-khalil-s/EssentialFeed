//
//  SharedTestHelpers.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 25/09/21.
//

import Feed

func anyNSError() -> NSError {
    return NSError(domain: "Any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "www.apple.com")!)]
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTile: String {
    ImageCommentsPresenter.title
}
