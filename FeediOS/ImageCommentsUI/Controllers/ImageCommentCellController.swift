//
//  ImageCommentCellController.swift
//  FeediOS
//
//  Created by Sergio Khalil Bello Garcia on 07/05/22.
//

import UIKit
import Feed

public class ImageCommentCellController: CellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel){
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.commentLabel.text = model.comment
        cell.dateLabel.text = model.date
        cell.userNameLabel.text = model.name
        return cell
    }
    
    public func preload() {
    }
    
    public func cancelLoad() {
    }
}
