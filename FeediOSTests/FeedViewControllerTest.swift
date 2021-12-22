//
//  FeedViewControllerTest.swift
//  FeediOSTests
//
//  Created by Sergio Khalil Bello Garcia on 21/12/21.
//

import UIKit
import XCTest

final class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTest.LoaderSpy?
    
    convenience init(loader: FeedViewControllerTest.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        loader?.load()
    }
    
}

final class FeedViewControllerTest: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}
