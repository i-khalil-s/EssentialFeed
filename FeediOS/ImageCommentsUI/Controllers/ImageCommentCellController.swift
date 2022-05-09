//
//  ImageCommentCellController.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 07/05/22.
//

import UIKit
import Feed

public class ImageCommentCellController: NSObject, UITableViewDataSource {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel){
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.commentLabel.text = model.comment
        cell.commentLabel.font = .preferredFont(forTextStyle: .body)
        cell.commentLabel.adjustsFontForContentSizeCategory = true
        cell.dateLabel.text = model.date
        cell.dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        cell.dateLabel.adjustsFontForContentSizeCategory = true
        cell.userNameLabel.text = model.name
        cell.userNameLabel.font = .preferredFont(forTextStyle: .headline)
        cell.userNameLabel.adjustsFontForContentSizeCategory = true
        return cell
    }
    
}
