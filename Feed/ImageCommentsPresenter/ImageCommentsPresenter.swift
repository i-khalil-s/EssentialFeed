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
    
}
