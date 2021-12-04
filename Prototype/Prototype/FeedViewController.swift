//
//  FeedViewController.swift
//  Prototype
//
//  Created by Sergio Khalil Bello Garcia on 03/12/21.
//

import UIKit

final class FeedViewController: UITableViewController {
    private let feed = FeedImageViewModel.prototypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
        
        let model = feed[indexPath.row]
        
        cell.configure(with: model)
        return cell
    }
}

extension FeedImageCell {
    
    func configure(with model: FeedImageViewModel) {
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        
        feedImageView.image = UIImage(named: model.imageName)
        
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
    }
}
