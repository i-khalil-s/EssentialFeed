//
//  FeedPresenterTests.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/03/22.
//

import Foundation
import XCTest
import Feed

final class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_map_createsViewModels() {
        let feed = uniqueImageFeed().models
        
        let viewModel = FeedPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed)
    }
    
    
    //MARK: Helpers
    
    private func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing Localized string for key: \(key) in table \(table).", file: file, line: line)
        }
        return value
    }
}
