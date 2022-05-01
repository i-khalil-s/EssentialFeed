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

class FeedItemsMapperTests: XCTestCase {
    
    // MARK: Happy paths
    
    func test_map_deliversNoItemsOn200HTTPResponse() throws {
        let emptyListJSON = makeItemsJSON([])
        
        let result = try FeedItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithValidJSON() throws {
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "http://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "A descrip", location: "A location", imageURL: URL(string: "http://another-url.com")!)
        let items = [item1.model, item2.model]
        let itemsJSON = makeItemsJSON([item1.json, item2.json])
        
        let result = try FeedItemsMapper.map(itemsJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, items)
    }

    //MARK: Sad paths
    func test_load_throwsErrorOnNot200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid jSON".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    /// MARK: Helpers
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
    
}
