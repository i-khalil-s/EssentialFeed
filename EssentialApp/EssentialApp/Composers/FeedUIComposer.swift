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
    ) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue()})
        
        let feedController = FeedUIComposer.makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title
        )
        
        let presenter = FeedPresenter(
            feedView: FeedViewAdapter(
                controller: feedController,
                loader: { imageLoader($0).dispatchOnMainQueue() }
            ),
            errorView: WeakRefVirtualProxy(feedController),
            loadingView: WeakRefVirtualProxy(feedController)
        )
        presentationAdapter.presenter = presenter
        return feedController
    }
}

private extension FeedUIComposer {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        
        return feedController
    }
}
