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
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: viewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        viewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        
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
