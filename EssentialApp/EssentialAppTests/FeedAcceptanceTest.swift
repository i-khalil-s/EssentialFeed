//
//  FeedAcceptanceTest.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 14/04/22.
//

import XCTest
import Feed
import FeediOS
@testable import EssentialApp

final class FeedAcceptanceTest: XCTestCase {
    
    func  test_onLaunch_displaysRemoteFeedWhenUserHasConnectivity() {
        let store = InMemoryFeedStore.empty
        let client = HTTPClientStub.online(response)
        let feed = launch(httpClient: client, store: store)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.simulateFeedImageViewVisible(at:0)?.renderedImage, makeImageData())
        XCTAssertEqual(feed.simulateFeedImageViewVisible(at: 1)?.renderedImage, makeImageData())
    }
    
    func  test_onLaunch_displaysCachedRemoteFeedWhenUserHasNoConnectivity() {
        
    }
    
    func  test_onLaunch_displaysEmptyFeedWhenUserHasNoConnectivityAndNoCache() {
        
    }
    
    //MARK: Helpers
    private func launch(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) -> FeedViewController {
        let store = InMemoryFeedStore.empty
        let client = HTTPClientStub.online(response)
        let sut = SceneDelegate(httpClient: client, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }
        
        private let stub: (URL) -> HTTPClient.Result
        
        init(stub: @escaping (URL) -> Result<(Data, HTTPURLResponse), Error>) {
            self.stub = stub
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }
        
        static var offline: HTTPClientStub {
            HTTPClientStub(stub: {_ in .failure(anyNSError())})
        }
        
        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url))}
        }
    }
    
    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        private var cachedFeed: CachedFeed?
        private var feedImageDataCache: [URL: Data] = [:]
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            cachedFeed = nil
            completion(.success(()))
        }
        
        func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            cachedFeed = CachedFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }
        
        func retreive(completion: @escaping RetreivalCompletion) {
            completion(.success(cachedFeed))
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            feedImageDataCache[url] = data
            completion(.success(()))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
            completion(.success(feedImageDataCache[url]))
        }
        
        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [ "items" : [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]
        ])
    }
}
