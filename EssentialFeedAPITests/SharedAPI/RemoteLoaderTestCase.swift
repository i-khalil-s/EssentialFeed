//
//  RemoteLoader<String>TestCase.swift
//  EssentialFeedAPITests
//
//  Created by Sergio Khalil Bello Garcia on 25/04/22.
//

import Foundation
import XCTest
import Feed
import EssentialFeedAPI

class RemoteLoaderTestCase: XCTestCase {
    
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
    
    func test_load_deliversMappedResource() {
        let resource = "a resource"
        let (sut,client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })
        
        expect(sut, toCompleteWith: .success(resource)) {
            client.complete(withStatus: 200, data: Data(resource.utf8))
        }
        
    }

    //MARK: Sad paths
    
    func test_init_DoesNotRequestDateFromURL() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_load_deliversErrorOnClientFailure() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnMapperError() {
        let (sut,client) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatus: 200, data: anyData())
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: { _, _ in anyString() })
        
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load {
            capturedResults.append($0)
        }
        sut = nil
        client.complete(withStatus: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    /// MARK: Helpers
    private func expect(_ sut: RemoteLoader<String>, toCompleteWith expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp] , timeout: 1.0)
        
    }
    
    private func makeSUT(
        url: URL = URL(string: "http://a-url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = {_, _ in anyString()},
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        //System Under Test
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String:Any]) {
        let feedItem = FeedImage(id: id, description: description, location: location, url: imageURL)
        
        let json = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.url.absoluteString
        ].compactMapValues {$0}
        
        return (feedItem, json)
    }
    
    func makeItemsJSON(_ items: [[String:Any]]) -> Data{
        let itemsJSON = [
            "items" : items
        ]
        return  try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
}

func anyString() -> String {
    "any"
}

func anyData() -> Data {
    anyString().data(using: .utf8)!
}
