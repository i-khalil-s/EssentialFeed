//
//  CoreDataFeedStore+FeedStore.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 24/03/22.
//

import Foundation
import CoreData

extension CoreDataFeedStore: FeedStore {
     public func retreive(completion: @escaping RetreivalCompletion) {
         perform { context in
             completion(Result {
                 try ManagedCache.find(in: context).map {
                     CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                 }
             })
         }
     }

     public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
         perform { context in
             completion(Result {
                 let managedCache = try ManagedCache.newUniqueInstance(in: context)
                 managedCache.timestamp = timestamp
                 managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                 try context.save()
             })
         }
     }

     public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
         perform { context in
             completion(Result {
                 try ManagedCache.find(in: context).map(context.delete).map(context.save)
             })
         }
     }

 }
