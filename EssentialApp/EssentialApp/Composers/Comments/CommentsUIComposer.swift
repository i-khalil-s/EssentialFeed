//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Sergio Khalil Bello Garcia on 12/05/22.
//

import Combine
import Feed
import UIKit
import FeediOS

public final class CommentsUIComposer {
    
    private init () {}
    
    public static func commentsComposedWith(
        commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
    ) -> ListViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>(feedLoader: { commentsLoader().dispatchOnMainQueue()})
        
        let commentsController = makeWith(
            title: ImageCommentsPresenter.title
        )
        
        commentsController.onRefresh = presentationAdapter.loadResource
        
        let presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(
                controller: commentsController
            ),
            errorView: WeakRefVirtualProxy(commentsController),
            loadingView: WeakRefVirtualProxy(commentsController),
            mapper: { ImageCommentsPresenter.map($0) }
        )
        presentationAdapter.presenter = presenter
        return commentsController
    }
}

private extension CommentsUIComposer {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let commentsController = storyboard.instantiateInitialViewController() as! ListViewController
        commentsController.title = title
        
        return commentsController
    }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { model in
            CellController(id: viewModel, dataSource: ImageCommentCellController(model: model))
        })
    }
    
}
