//
//  FeedUIComposer.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 06/01/22.
//

import Feed
import UIKit

public final class FeedUIComposer {
    
    private init () {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedPresenter: presenter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presenter.loadingView = refreshController
        presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { feedModel in
                return FeedImageCellController(
                    viewModel: FeedImageViewModel(model: feedModel, imageLoader: loader, imageTransformer: UIImage.init)
                )
            }
        }
    }
}

private final class FeedViewAdapter: FeedView {
        
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { feedModel in
            return FeedImageCellController(
                viewModel: FeedImageViewModel(model: feedModel, imageLoader: loader, imageTransformer: UIImage.init)
            )
        }
    }
    
}
