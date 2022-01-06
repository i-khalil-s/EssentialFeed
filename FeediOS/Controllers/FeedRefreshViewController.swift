//
//  FeedRefreshViewController.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 05/01/22.
//

import UIKit
import Feed

final public class FeedRefreshViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                self.onRefresh?(feed)
            }
            self.view.endRefreshing()
        }
    }
}
