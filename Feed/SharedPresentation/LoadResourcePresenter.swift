//
//  LoadResourcePresenter.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 01/05/22.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    private let resourceView: View
    private let errorView: ResourceErrorView
    private let loadingView: ResourceLoadingView
    private let mapper: Mapper
    
    public init(resourceView: View, errorView: ResourceErrorView, loadingView: ResourceLoadingView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.errorView = errorView
        self.loadingView = loadingView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(.init(isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: Self.loadError))
        loadingView.display(.init(isLoading: false))
    }
    
    public static var loadError: String {
        return NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed wwhen we cannot load the resource from server"
        )
    }
}
