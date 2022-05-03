//
//  SharedLocalizationTests.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 02/05/22.
//

import Feed
import XCTest

class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalization() {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
    
}
