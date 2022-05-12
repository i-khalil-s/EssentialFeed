//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Sergio Khalil Bello Garcia on 12/05/22.
//

import Combine
import Feed
import UIKit
import FeediOS

public final class CommentsUIComposer {
    
    private init () {}
    
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> FeedLoader.Publisher
    ) -> ListViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(feedLoader: { commentsLoader().dispatchOnMainQueue()})
        
        let feedController = FeedUIComposer.makeWith(
            title: ImageCommentsPresenter.title
        )
        
        feedController.onRefresh = presentationAdapter.loadResource
        
        let presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                loader: { _ in Empty<Data,Error>().eraseToAnyPublisher() }
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
