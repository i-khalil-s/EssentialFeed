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
        session.dataTask(with: url) {_,_,_ in}.resume()
    }
    
    
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getURL_resumesDataTaskWithURL() {
        
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, with: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
//   MARK :Helpers
    
    private class URLSessionSpy: URLSession {
        
        var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, with dataTask: URLSessionDataTask) {
            stubs[url] = dataTask
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
            
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
