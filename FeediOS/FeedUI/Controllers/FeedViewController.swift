//
//  FeedViewController.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 22/12/21.
//

import UIKit
import Feed

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

final public class FeedViewController: UITableViewController {
    private var tableModel = [FeedImageCellController]() {
        didSet { self.tableView.reloadData() }
    }
    
    public var delegate: FeedViewControllerDelegate?
    public override func viewDidLoad() {
        refresh()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    private var loadingControllers = [IndexPath: FeedImageCellController]()
    
    public func display(_ cellControllers: [FeedImageCellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellController(forRowAt: indexPath)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func cancelCellController(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellController)
    }
}

extension FeedViewController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}

extension FeedViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        let alert = UIAlertController(title: viewModel.message, message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
}
