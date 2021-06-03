//
//  RemoteFeedLoaderTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/06/21.
//

import XCTest
class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_DoesNotRequestDateFromURL() {
        let client = HTTPClient()
//        System Under Test (SUT)
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
        
    }
}
