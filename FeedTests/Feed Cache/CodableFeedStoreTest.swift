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
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp1 = expectation(description: "Wait for cache retrieval to complete")
        
        sut.retreive { firstResult in
            sut.retreive { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected receiving twice from empty cache to deliver same empty result, but got \(firstResult) and \(secondResult) instead")
                }
                exp1.fulfill()
            }
        }
        
        wait(for: [exp1], timeout: 1.0)
        
    }

}
