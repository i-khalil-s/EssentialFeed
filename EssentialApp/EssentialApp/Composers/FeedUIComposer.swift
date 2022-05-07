//
//  FeedUIComposer.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 06/01/22.
//

import Combine
import Feed
import UIKit
import FeediOS

public final class FeedUIComposer {
    
    private init () {}
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> FeedLoader.Publisher,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> ListViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(feedLoader: { feedLoader().dispatchOnMainQueue()})
        
        let feedController = FeedUIComposer.makeWith(
            title: FeedPresenter.title
        )
        
        feedController.onRefresh = presentationAdapter.loadResource
        
        let presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                loader: { imageLoader($0).dispatchOnMainQueue() }
            ),
            errorView: WeakRefVirtualProxy(feedController),
            loadingView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map
        )
        presentationAdapter.presenter = presenter
        return feedController
    }
}

private extension FeedUIComposer {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        
        return feedController
    }
}
