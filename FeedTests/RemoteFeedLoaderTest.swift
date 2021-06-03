//
//  RemoteFeedLoaderTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/06/21.
//

import XCTest

//--------Production code
class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "http://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) {}
    
}
//--------Production code
//--------Test Code
class HTTPClientSpy: HTTPClient {
    
    override func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_DoesNotRequestDateFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
//        System Under Test (SUT)
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
