//
//  FeedPresenterTests.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/03/22.
//

import Foundation
import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    //MARK: Helpers
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
