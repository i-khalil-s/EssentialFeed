//
//  FactoryMethods.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 16/09/21.
//

import Feed

public func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: anyString(), location: anyString(), url: anyURL())
}

public func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    return (models, local)
}

public func anyString() -> String {
    return "any string"
}

public extension Date {

    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
}
