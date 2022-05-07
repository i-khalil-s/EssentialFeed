//
//  FeedViewAdapter.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 18/02/22.
//

import Feed
import UIKit
import FeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(
                model: model,
                imageLoader: loader
            )
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )
            
            return view
        })
    }
    
}
