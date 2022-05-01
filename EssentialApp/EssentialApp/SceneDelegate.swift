//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Sergio Khalil Bello Garcia on 23/03/22.
//

import UIKit
import Feed
import FeediOS
import CoreData
import EssentialFeedAPI
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let localStoreURL = NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("feed-store.sqlite")
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore  = {
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = UINavigationController(rootViewController:
            FeedUIComposer.feedComposedWith(
                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                imageLoader: makeLocalImageDataFeedLoaderWithRemoteFallback
            )
        )
        window?.makeKeyAndVisible()
    }
    
    func makeRemoteClient() -> HTTPClient {
        httpClient
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        localFeedLoader.validateCache() { _ in }
    }

    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential-app-feed.json"
        )!
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalImageDataFeedLoaderWithRemoteFallback(for url: URL) -> FeedImageDataLoader.Publisher {
        let remoteFeedImageDataLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localFeedImageDataLoader = LocalFeedImageDataLoader(store: store)
        
        return localFeedImageDataLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteFeedImageDataLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localFeedImageDataLoader, using: url)
            })
    }
}

extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}
