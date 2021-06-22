//
//  URLSessionHTTPClientTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 22/06/21.
//

import XCTest
import Feed

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    internal init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPResponse) -> Void) {
        session.dataTask(with: url) {_,_,error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getURL_resumesDataTaskWithURL() {
        
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, with: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) {_ in}
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsRequestOnError() {
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let expectedError = NSError(domain: "Any error", code: 1)
        session.stub(url: url, error: expectedError)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait for block")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertEqual(expectedError, receivedError as NSError)
            default:
                XCTFail("Expected failure with error \(expectedError) but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
//   MARK :Helpers
    
    private class URLSessionSpy: URLSession {
        
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
            let task: URLSessionDataTask
        }
        
        func stub(url: URL, with dataTask: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(error: error, task: dataTask)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't found stub for \(url) url")
                
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
            
            
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
