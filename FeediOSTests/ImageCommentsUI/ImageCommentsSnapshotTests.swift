//
//  ImageCommentsSnapshotTests.swift
//  FeediOSTests
//
//  Created by Sergio Khalil Bello Garcia on 07/05/22.
//

import Foundation
import XCTest
import FeediOS
@testable import Feed

final class ImageCommentsSnapshotTests: XCTestCase {
    
    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
    }
    
    
    // MARK: Helpers
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyBoard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyBoard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func comments() -> [CellController] {
        commentsControllers().map { CellController($0, nil, nil) }
    }
    
    private func commentsControllers() -> [ImageCommentCellController] {
        return [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    name: "A long long long user name",
                    comment: "The East Side Gallery memorial in Berlin-Friedrichshain is a permanent open-air gallery on the longest surviving section of the Berlin Wall in Mühlenstraße.",
                    date: "1000 years ago"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    name: "A user name",
                    comment: "The East Side Gallery memorial",
                    date: "10 days ago"
                )
            )
            ,
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    name: "A user name",
                    comment: "Nice",
                    date: "1 hour ago"
                )
            )
        ]
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    weak var controller: FeedImageCellController?
    let viewModel: FeedImageViewModel<UIImage>
    
    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {}
    
    
}
