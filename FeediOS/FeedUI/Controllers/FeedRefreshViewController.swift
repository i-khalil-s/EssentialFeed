//
//  FeedRefreshViewController.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 05/01/22.
//

import UIKit

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private(set) lazy var view = loadView()
    
    private var feedPresenter: FeedPresenter
    
    init(feedPresenter: FeedPresenter) {
        self.feedPresenter = feedPresenter
    }
    
    @objc func refresh() {
        feedPresenter.loadFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
