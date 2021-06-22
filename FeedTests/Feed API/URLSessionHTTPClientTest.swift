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
    
    internal init(session: URLSession = .shared) {
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
    
    func test_getFromURL_failsRequestOnError() {
        URLProtocolStub.startInterceptingRequest()
    
        let url = URL(string: "http://a-url.com")!
        let expectedError = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: expectedError)
        let sut = URLSessionHTTPClient()
        
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
        URLProtocolStub.stopInterceptingRequest()
    }
    
//   MARK :Helpers
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
             
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
