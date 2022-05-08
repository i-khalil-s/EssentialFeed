//
//  FeedViewController.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 22/12/21.
//

import UIKit
import Feed

public typealias CellController = (dataSource: UITableViewDataSource, delegate: UITableViewDelegate?, prefetching: UITableViewDataSourcePrefetching?)

final public class ListViewController: UITableViewController {
    private var tableModel = [CellController]() {
        didSet { self.tableView.reloadData() }
    }
    
    public var onRefresh: (() -> Void)?
    public override func viewDidLoad() {
        refresh()
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    private var loadingControllers = [IndexPath: CellController]()
    
    public func display(_ cellControllers: [CellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controller = cellController(forRowAt: indexPath).dataSource
        return controller.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(forRowAt: indexPath)?.delegate
        controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func removeLoadingController(forRowAt indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
}

extension ListViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath).prefetching
            controller?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = removeLoadingController(forRowAt: indexPath)?.prefetching
            controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
}

extension ListViewController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}

extension ListViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        let alert = UIAlertController(title: viewModel.message, message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
}
