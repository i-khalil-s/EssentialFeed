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
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.simulateFeedImageViewVisible(at:0)?.renderedImage, makeImageData())
        XCTAssertEqual(feed.simulateFeedImageViewVisible(at: 1)?.renderedImage, makeImageData())
    }
    
    func  test_onLaunch_displaysCachedRemoteFeedWhenUserHasNoConnectivity() {
        let store = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: store)
        onlineFeed.simulateNearVisibleImage(at: 0)
        onlineFeed.simulateNearVisibleImage(at: 1)
        
        let offlineFeed = launch(httpClient: .offline, store: store)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.simulateFeedImageViewVisible(at:0)?.renderedImage, makeImageData())
        XCTAssertEqual(offlineFeed.simulateFeedImageViewVisible(at: 1)?.renderedImage, makeImageData())
    }
    
    func  test_onLaunch_displaysEmptyFeedWhenUserHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBsckGround_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.expired
        
        enterBackground(with: store)
        
        XCTAssertNil(store.cachedFeed, "Expected expired cache to be gone")
    }
    
    func test_onEnteringBsckGround_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.notExpired
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.cachedFeed, "Expected cache not to be nil")
    }
    
    //MARK: Helpers
    private func launch(httpClient: HTTPClientStub, store: InMemoryFeedStore) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
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
        var cachedFeed: CachedFeed?
        private var feedImageDataCache: [URL: Data] = [:]
        
        private init(cachedFeed: CachedFeed? = nil) {
            self.cachedFeed = cachedFeed
        }
        
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
        
        static var expired: InMemoryFeedStore {
            InMemoryFeedStore(cachedFeed: CachedFeed(feed: [], timestamp: Date.distantPast))
        }
        
        static var notExpired: InMemoryFeedStore {
            InMemoryFeedStore(cachedFeed: CachedFeed(feed: [], timestamp: Date()))
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
