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
    
    func test_load_deliversNoItemsOn200HTTPResponse() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data("{\"items\":[]}".utf8)
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
    
    func test_init_DoesNotRequestDateFromURL() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_load_deliversErrorOnClientFailure() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNot200HTTPResponse() {
        let (sut,client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (idx,code) in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatus: code, data: json, at: idx)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut,client) = makeSUT()
        
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid jSON".utf8)
            client.complete(withStatus: 200, data: invalidJSON)
        })
    }
    
    /// MARK: Helpers
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPResponseError) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map{$0.url}
        }
        
        func get(from url: URL, completion: @escaping (HTTPResponseError) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatus code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
        
    }
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        //System Under Test
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String:Any]) {
        let feedItem = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": feedItem.id.uuidString,
            "description": feedItem.description,
            "location": feedItem.location,
            "image": feedItem.imageURL.absoluteString
        ].compactMapValues {$0}
        
        return (feedItem, json)
    }
    
    func makeItemsJSON(_ items: [[String:Any]]) -> Data{
        let itemsJSON = [
            "items" : items
        ]
        return  try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut.load { result in
            capturedResults.append(result)
        }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
}
