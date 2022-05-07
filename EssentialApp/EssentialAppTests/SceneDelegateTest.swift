//
//  SceneDelegateTest.swift
//  EssentialAppTests
//
//  Created by Sergio Khalil Bello Garcia on 14/04/22.
//

import UIKit
import FeediOS
import XCTest
@testable import EssentialApp

final class SceneDelegateTest: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindow()
        let sut = SceneDelegate()
        
        sut.window = window
        sut.configureWindow()
        
        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }
    
    func test_configureWindow_configuresViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topViewController = rootNavigation?.topViewController
        
        XCTAssertNotNil(rootNavigation, "Expected a UINavigationController ar a root, got \(String(describing: rootNavigation)) instead")
        XCTAssertTrue(topViewController is ListViewController, "Expected `FeedViewController` as the top view controller but got \(String(describing: topViewController)) instead")
    }
}
