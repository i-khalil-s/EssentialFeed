//
//  ImageCommentsPresenter.swift
//  Feed
//
//  Created by Sergio Khalil Bello Garcia on 05/05/22.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the image comments View"
        )
    }
    
    public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        return ImageCommentsViewModel(comments: comments.map { comment in
            ImageCommentViewModel(
                name: comment.userName,
                comment: comment.message,
                date: formatter.localizedString(for: comment.createdAt, relativeTo: Date())
            )
        })
    }
}

public struct ImageCommentsViewModel: Equatable {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    public let name: String
    public let comment: String
    public let date: String
    
    public init(name: String, comment: String, date: String) {
        self.name = name
        self.comment = comment
        self.date = date
    }
}
