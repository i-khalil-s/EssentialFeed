//
//  LoadResourcePresenter.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 01/05/22.
//

import Foundation

public protocol ResourceView {
    func display(_ viewModel: String)
}

public class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    private let resourceView: ResourceView
    private let errorView: ErrorView
    private let loadingView: FeedLoadingView
    private let mapper: Mapper
    
    public init(resourceView: ResourceView, errorView: ErrorView, loadingView: FeedLoadingView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.errorView = errorView
        self.loadingView = loadingView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: String) {
        resourceView.display(mapper(resource))
        loadingView.display(.init(isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(.init(isLoading: false))
    }
    
    private var feedLoadError: String {
        return NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed wwhen we cannot display image from server"
        )
    }
}
