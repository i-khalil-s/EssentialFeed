//
//  FeedLoaderPresentationAdapter.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 18/02/22.
//

import Feed
import FeediOS
import Combine

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(feedLoader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = feedLoader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader().sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished: break
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }, receiveValue: { [weak self] resource in
            self?.presenter?.didFinishLoading(with: resource)
        })
    }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        loadResource()
    }
}
