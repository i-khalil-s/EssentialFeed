//
//  ImageCommentsLocalizationTests.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 06/05/22.
//

import XCTest
import Feed

class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalization() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
    
}
