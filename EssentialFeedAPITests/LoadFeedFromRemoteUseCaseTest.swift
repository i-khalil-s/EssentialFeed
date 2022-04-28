//
//  RemoteFeedLoaderTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 03/06/21.
//

import XCTest
import EssentialFeedAPI
import Feed

//--------Production code

//--------Production code

class LoadFeedFromRemoteUseCaseTest: XCTestCase {
    
    // MARK: Happy paths
    
    func test_load_deliversNoItemsOn200HTTPResponse() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatus: 200, data: emptyListJSON)
        }
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithValidJSON() {
        let (sut,client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "http://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "A descrip", location: "A location", imageURL: URL(string: "http://another-url.com")!)
        
        let items = [item1.model, item2.model]
        let itemsJSON = [item1.json, item2.json]
        expect(sut, toCompleteWith: .success(items)) {
            client.complete(withStatus: 200, data: makeItemsJSON(itemsJSON))
        }
        
    }

    //MARK: Sad paths
    func test_load_deliversErrorOnNot200HTTPResponse() {
        let (sut,client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (idx,code) in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatus: code, data: json, at: idx)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut,client) = makeSUT()
        
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid jSON".utf8)
            client.complete(withStatus: 200, data: invalidJSON)
        })
    }
    
    /// MARK: Helpers
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp] , timeout: 1.0)
        
    }
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        //System Under Test
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
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
