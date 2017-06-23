//
//  AppFlowController+TrackerTests.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_TrackerTests: XCTestCase {
    
    // MARK: - Properties
    
    var tracker:Tracker!
    
    // MARK: - Setup
    
    override func setUp() {
        tracker = Tracker()
    }
    
    // MARK: - Tests
    
    // MARK: - register view controller
    
    func testResisterVC_itemForKeyDoesntExist() {
        let viewController = UIViewController()
        tracker.register(viewController: viewController, for: "key", skipped: true)
        XCTAssertEqual(tracker.viewController(for: "key"), viewController)
        XCTAssertNil(tracker.parameter(for: "key"))
        XCTAssertTrue(tracker.isItemSkipped(at: "key"))
    }
    
    func testResisterVC_itemForKeyAlreadyExists() {
        let viewController = UIViewController()
        tracker.register(viewController: UIViewController(), for: "key", skipped: false)
        tracker.register(viewController: viewController, for: "key", skipped: true)
        XCTAssertEqual(tracker.viewController(for: "key"), viewController)
        XCTAssertNil(tracker.parameter(for: "key"))
        XCTAssertTrue(tracker.isItemSkipped(at: "key"))
    }
    
    // MARK: - register parameter
    
    func testRegisterParameter_itemForKeyDoesntExist() {
        XCTAssertNil(tracker.parameter(for: "key"))
    }
    
    func testRegisterParameter_itemForKeyAlreadyExists_viewControllerIsNotNil() {
        let viewController = UIViewController()
        tracker.register(viewController: viewController, for: "key")
        tracker.register(parameter: "parameter", for: "key")
        XCTAssertEqual(tracker.parameter(for: "key"), "parameter")
    }
    
    func testRegisterParameter_itemForKeyAlreadyExists_viewControllerIsNil() {
        tracker.register(parameter: "parameter", for: "key")
        XCTAssertNil(tracker.parameter(for: "key"))
    }
    
    // MARK: - view controller for key
    
    func testViewControllerForKey_itemForKeyDoesntExist() {
        XCTAssertNil(tracker.viewController(for: "key"))
    }
    
    func testViewControllerForKey_itemForKeyAlreadyExists() {
        let viewController = UIViewController()
        tracker.register(viewController: viewController, for: "key")
        XCTAssertEqual(tracker.viewController(for: "key"), viewController)
    }
    
    // MARK: - key for view controller
    
    func testKeyForViewController_viewControllerIsNotRegistered() {
        tracker.register(viewController: UIViewController(), for: "key")
        XCTAssertNil(tracker.key(for: UIViewController()))
    }
    
    func testKeyForViewController_viewControllerIsRegistered() {
        let viewController = UIViewController()
        tracker.register(viewController: viewController, for: "key")
        XCTAssertEqual(tracker.key(for: viewController), "key")
    }
    
    // MARK: - parameter for key
    
    // already testes in previous tests
    
    // MARK: - is item skipped
    
    func testIsItemSkipped_itemIsNotRegisteredToSkip() {
        tracker.register(viewController: UIViewController(), for: "key", skipped: true)
        XCTAssertFalse(tracker.isItemSkipped(at: "another_key"))
    }
    
    func testIsItemSkipped_itemIsRegisteredToSkip() {
        tracker.register(viewController: UIViewController(), for: "key", skipped: true)
        XCTAssertTrue(tracker.isItemSkipped(at: "key"))

    }
    
    // MArK: - disable skip
    
    func testDisableSkip_itemIsRegisteredToSkip_keyToDisableIsCorrect() {
        tracker.register(viewController: UIViewController(), for: "key", skipped: true)
        tracker.disableSkip(for: "another_key")
        XCTAssertTrue(tracker.isItemSkipped(at: "key"))
    }
    
    func testDisableSkip_itemIsRegisteredToSkip_keyToDisableIsIncorrect() {
        tracker.register(viewController: UIViewController(), for: "key", skipped: true)
        tracker.disableSkip(for: "key")
        XCTAssertFalse(tracker.isItemSkipped(at: "key"))
    }
    
    func testDisableSkip_itemIsNotRegisteredToSkip() {
        tracker.register(viewController: UIViewController(), for: "key", skipped: false)
        tracker.disableSkip(for: "key")
        XCTAssertFalse(tracker.isItemSkipped(at: "key"))
    }
    
    func testDisableSkip_itemForKeyDoesntExist() {
        tracker.disableSkip(for: "key")
        XCTAssertFalse(tracker.isItemSkipped(at: "key"))
    }
    
    // MARK: - reset
    
    func testReset_thereAreNoItems() {
        tracker.reset()
        XCTAssertTrue(tracker.isEmpty())
    }
    
    func testReset_thereAreAlreadyItemsInside() {
        tracker.register(viewController: UIViewController(), for: "key", skipped: true)
        tracker.reset()
        XCTAssertTrue(tracker.isEmpty())
    }
    
    // MARK: - is empty
    
    func testIsEmpty_thereAreNoItems() {
        XCTAssertTrue(tracker.isEmpty())
    }
    
    func testIsEmpty_thereAreAlreadyItemsInside() {
        tracker.register(viewController: UIViewController(), for: "key", skipped: false)
        XCTAssertFalse(tracker.isEmpty())
    }
    
}
