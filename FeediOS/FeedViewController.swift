//
//  FeedViewController.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 22/12/21.
//

import UIKit
import Feed

final public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
        }
    }
    
}
