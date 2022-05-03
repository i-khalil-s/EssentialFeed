//
//  FeedLocalizationTest.swift
//  FeediOSTests
//
//  Created by Sergio Khalil Bello Garcia on 15/02/22.
//

import XCTest
import Feed

class FeedLocalizationTest: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalization() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
}
