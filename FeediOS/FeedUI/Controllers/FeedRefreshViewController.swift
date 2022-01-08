//
//  FeedRefreshViewController.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 05/01/22.
//

import UIKit

final public class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view = binded(UIRefreshControl())
    
    private var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            guard let view = view else { return }
            if isLoading {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
            
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
