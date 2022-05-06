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
