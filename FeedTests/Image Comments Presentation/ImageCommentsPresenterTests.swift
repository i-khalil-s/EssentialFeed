//
//  ImageCommentsPresenterTests.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 05/05/22.
//

import Foundation
import XCTest
import Feed

final class ImageCommentsPresenterTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_map_createsViewModels() {
        let now = Date()
        let comments = [
            ImageComment(id: UUID(), message: "Message", createdAt: now.adding(minutes: -5), userName: "Name"),
            ImageComment(id: UUID(), message: "Another message", createdAt: now.adding(days: -1), userName: "Another name")
        ]
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        
        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                name: "Name",
                comment: "Message",
                date: "5 minutes ago"
            ),
            ImageCommentViewModel(
                name: "Another name",
                comment: "Another message",
                date: "1 day ago"
            )
        ])
    }
    
    //MARK: Helpers
    
    private func localized(_ key: String, table: String = "ImageComments", file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing Localized string for key: \(key) in table \(table).", file: file, line: line)
        }
        return value
    }
}
