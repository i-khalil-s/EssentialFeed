//
//  URLSessionHTTPClientTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 22/06/21.
//

import XCTest

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    internal init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) {_,_,_ in}
    }
    
    
}

class URLSessionHTTPClientTest: XCTestCase {

    func test_getURL_createsDataTaskWithURL() {
        
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
//   MARK :Helpers
    
    private class URLSessionSpy: URLSession {
        
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            self.receivedURLs.append(url)
            return FakeURLSessionDataTask()
            
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
}
