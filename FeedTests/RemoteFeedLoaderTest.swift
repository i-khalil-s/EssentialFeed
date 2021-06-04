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
    
    // MARK: Happy paths
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{_ in}
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    //MARK: Sad paths
    
    func test_init_DoesNotRequestDateFromURL() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_load_deliversErrorOnClientFailure() {
        let (sut,client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { error in
            capturedErrors.append(error)
        }
        
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNot200HTTPResponse() {
        let (sut,client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (idx,code) in
            var capturedErrors = [RemoteFeedLoader.Error]()
            
            sut.load { error in
                capturedErrors.append(error)
            }
            client.complete(withStatus: code, at: idx)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    /// MARK: Helpers
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(withStatus code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
            messages[index].completion(nil, response)
        }
        
    }
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        //System Under Test
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}
