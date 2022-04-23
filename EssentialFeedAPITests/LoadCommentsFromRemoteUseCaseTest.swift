//
//  LoadCommentsFromRemoteUseCaseTest.swift
//  EssentialFeedAPITests
//
//  Created by Sergio Khalil Bello Garcia on 23/04/22.
//

import Foundation
import XCTest
import EssentialFeedAPI
import Feed

class LoadCommentsFromRemoteUseCaseTest: XCTestCase {
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
    
    func test_load_deliversNoItemsOn2xxHTTPResponse() {
        let (sut,client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { (idx,code) in
            expect(sut, toCompleteWith: .success([])) {
                let emptyListJSON = makeItemsJSON([])
                client.complete(withStatus: code, data: emptyListJSON, at: idx)
            }
        }
        
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithValidJSON() {
        let (sut,client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            message: "A message",
            createdAt: (date: Date.init(timeIntervalSince1970: 1598627222), iso8601String: "2020-08-28T15:07:02+00:00"),
            userName: "Khalil"
        )
        let item2 = makeItem(
            id: UUID(),
            message: "Another message",
            createdAt: (date: Date.init(timeIntervalSince1970: 1577881882), iso8601String: "2020-01-01T12:31:22+00:00"),
            userName: "Fernanda"
        )
        
        let items = [item1.model, item2.model]
        let itemsJSON = [item1.json, item2.json]
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { (idx,code) in
            expect(sut, toCompleteWith: .success(items)) {
                client.complete(withStatus: code, data: makeItemsJSON(itemsJSON), at: idx)
            }
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
    
    func test_load_deliversErrorOnNot2xxHTTPResponse() {
        let (sut,client) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
        
        samples.enumerated().forEach { (idx,code) in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatus: code, data: json, at: idx)
            })
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut,client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { (idx,code) in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("invalid jSON".utf8)
                client.complete(withStatus: code, data: invalidJSON, at: idx)
            })
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load {
            capturedResults.append($0)
        }
        sut = nil
        client.complete(withStatus: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    /// MARK: Helpers
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp] , timeout: 1.0)
        
    }
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        //System Under Test
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), userName: String) -> (model: ImageComment, json: [String:Any]) {
        let commentItem = ImageComment(id: id, message: message, createdAt: createdAt.date, userName: userName)
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": userName
            ]
        ]
        
        return (commentItem, json)
    }
    
    func makeItemsJSON(_ items: [[String:Any]]) -> Data{
        let itemsJSON = [
            "items" : items
        ]
        return  try! JSONSerialization.data(withJSONObject: itemsJSON)
    }
}
