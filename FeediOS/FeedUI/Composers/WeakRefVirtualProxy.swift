//
//  WeakRefVirtualProxy.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 18/02/22.
//

import Feed
import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
     func display(_ model: FeedImageViewModel<UIImage>) {
         object?.display(model)
     }
 }

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ErrorView where T: ErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}
