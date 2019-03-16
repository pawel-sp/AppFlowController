//
//  AppFlowController+CoreTests+Reset.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 26.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {
    
    // MARK: - Helpers
    
    class MockTracker: Tracker {
        
        var resetCount: Int = 0
        
        override func reset() {
            resetCount += 1
        }
        
    }
    
    // MARK: - Tests
    
    func testReset_shouldDismissAllPresentedViewControllers() {
        let flowController           = AppFlowController()
        let mockNavigationController = MockNavigationController()
        flowController.prepare(for: UIWindow(), rootNavigationController: mockNavigationController)
        flowController.reset()
        XCTAssertTrue(mockNavigationController.didDismissAllPresentedViewControllers!)
    }
    
    func testReset_shouldRemoveAllViewControllers() {
        let flowController           = AppFlowController()
        let mockNavigationController = MockNavigationController()
        mockNavigationController.viewControllers = [UIViewController()]
        flowController.prepare(for: UIWindow(), rootNavigationController: mockNavigationController)
        flowController.reset()
        XCTAssertEqual(mockNavigationController.viewControllers, [])
    }
    
    func testReset_shouldResetTracker() {
        let flowController = AppFlowController(trackerClass: MockTracker.self)
        let mockNavigationController = MockNavigationController()
        mockNavigationController.viewControllers = [UIViewController()]
        flowController.prepare(for: UIWindow(), rootNavigationController: mockNavigationController)
        flowController.reset()
        XCTAssertEqual((flowController.tracker as! MockTracker).resetCount, 1)
    }
    
    func testReset_ShouldInvokeCompletionBlock() {
        let exp = expectation(description: "Block need to be invoked after dismissing all presented view controllers")
        let mockNavigationController = MockNavigationController()
        flowController.prepare(for: UIWindow(), rootNavigationController: mockNavigationController)
        flowController.reset(completion: exp.fulfill)
        waitForExpectations(timeout: 0) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
}
