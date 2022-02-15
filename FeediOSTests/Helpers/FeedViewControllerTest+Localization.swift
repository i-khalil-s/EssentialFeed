//
//  FeedViewControllerTest+Localization.swift
//  FeediOSTests
//
//  Created by Sergio Khalil Bello Garcia on 14/02/22.
//

import Foundation
import FeediOS
import XCTest

extension FeedViewControllerTest {
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing Localized string for key: \(key) in table \(table).", file: file, line: line)
        }
        return value
    }
}
