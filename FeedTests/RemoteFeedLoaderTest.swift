//
//  RemoteFeedLoaderTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/06/21.
//

import XCTest
import Feed

//--------Production code

//--------Production code

class RemoteFeedLoaderTest: XCTestCase {
    
    func test_init_DoesNotRequestDateFromURL() {
        let (_,client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    /// MARK: Helpers
    
    private class HTTPClientSpy: HTTPClient {
        
        func get(from url: URL) {
            requestedURL = url
        }
        
        var requestedURL: URL?
    }
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        //System Under Test
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}
