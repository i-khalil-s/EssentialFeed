//
//  RemoteFeedLoaderTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/06/21.
//

import XCTest

//--------Production code
class RemoteFeedLoader {
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "http://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
    
}
//--------Production code
//--------Test Code
class HTTPClientSpy: HTTPClient {
    
    func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_DoesNotRequestDateFromURL() {
        let client = HTTPClientSpy()
//        System Under Test (SUT)
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
