//
//  FeedStoreSpy.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 16/09/21.
//

import Feed

class FeedStoreSpy: FeedStore {
    
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    var retreiveCompletions = [RetreivalCompletion]()
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retreive
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func retreive(completion: @escaping RetreivalCompletion) {
        receivedMessages.append(.retreive)
        retreiveCompletions.append(completion)
    }
    
    func completeRetreival(with error: NSError, at index: Int = 0) {
        retreiveCompletions[index](.failure(error))
    }
    
    func completeRetreivalWithEmptyCache(at index: Int = 0) {
        retreiveCompletions[index](.success(.none))
    }
    
    func completeRetreival(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retreiveCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
    }
    
}
