//
//  CodableFeedStoreTest.swift
//  FeedTests
//
//  Created by Sergio Khalil Bello Garcia on 27/09/21.
//

import XCTest
import Feed

class CodableFeedStore {
    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTest: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval to complete")
        
        sut.retreive { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, but got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }

}
