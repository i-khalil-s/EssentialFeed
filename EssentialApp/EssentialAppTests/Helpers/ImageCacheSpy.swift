//
//  ImageCacheSpy.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 13/04/22.
//

import Feed

class ImageCacheSpy: FeedImageCache {
    private(set) var messages = [Message]()
    
    enum Message: Equatable {
        static func == (lhs: ImageCacheSpy.Message, rhs: ImageCacheSpy.Message) -> Bool {
            switch (lhs, rhs) {
            case let (.save(data, url, _), .save(dataR, urlR, _)):
                return data == dataR && url == urlR
            }
        }
        
        case save(data: Data, url: URL, completion: (SaveResult) -> Void)
    }
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        messages.append(.save(data: data, url: url, completion: completion))
    }
    
    func complete(at index: Int = 0) {
        switch messages[index] {
        case let .save(_, _, completion):
            completion(.success(()))
        }
    }
}
