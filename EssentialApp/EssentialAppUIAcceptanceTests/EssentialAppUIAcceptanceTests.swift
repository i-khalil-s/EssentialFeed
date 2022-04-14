//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Sergio Khalil Bello Garcia on 14/04/22.
//

import XCTest

class EssentialAppUIAcceptanceTests: XCTestCase {

    func  test_onLaunch_displaysRemoteFeedWhenUserHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        XCTAssertEqual(app.cells.count, 22)
        XCTAssertEqual(app.images.count, 4)
    }
}
