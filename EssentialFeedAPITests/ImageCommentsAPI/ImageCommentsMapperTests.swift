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

class ImageCommentsMapperTests: XCTestCase {
    // MARK: Happy paths
    
    func test_map_deliversNoItemsOn2xxHTTPResponse() throws {
        let emptyListJSON = makeItemsJSON([])
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
        
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithValidJSON() throws {
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
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(makeItemsJSON(itemsJSON), from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, items)
        }
        
    }

    //MARK: Sad paths
    
    func test_map_throwsErrorOnNot2xxHTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 150, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid jSON".utf8)
        
        let samples = [200, 201, 250, 280, 299]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    /// MARK: Helpers
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
}
