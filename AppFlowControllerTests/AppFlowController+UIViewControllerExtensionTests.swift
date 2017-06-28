//
//  AppFlowController+UIViewControllerExtensionTests.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 20.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_UIViewControllerExtensionTests: XCTestCase {

    // MARK: - topPresentedViewController
    
    func testTopPresentedViewController_returnsNilIfPresentedVCIsNil() {
        let viewController = UIViewController()
        XCTAssertNil(viewController.topPresentedViewController)
    }
    
    func testTopPresentedViewController_returnsPresentedViewControllerIfThereIsOnlyOne() {
        let viewController = UIViewController()
        let rootViewController = StubViewController()
        rootViewController.presentedViewControllerResult = viewController
        XCTAssertEqual(rootViewController.topPresentedViewController, viewController)
    }
    
    func testTopPresentedViewController_returnsTopPresentedViewControllerIfThereAreMoreThenOne() {
        let viewController1 = UIViewController()
        let viewController2 = StubViewController()
        let viewController3 = StubViewController()
        
        viewController2.presentedViewControllerResult = viewController1
        viewController3.presentedViewControllerResult = viewController2
        XCTAssertEqual(viewController3.topPresentedViewController, viewController1)
    }
    
    // MARK: - dismissAllPresentedViewControllers
    
    func testDismissAllPresentedViewControllers_invokesImmediatellyBlockIfThereAreNoViewControllers() {
        let navigationController = UINavigationController()
        let exp   = expectation(description: "Block need to be invoked after dismissing all presented view controllers")
        let block = { exp.fulfill() }
        navigationController.dismissAllPresentedViewControllers(completionBlock: block)
        waitForExpectations(timeout: 0) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testDismissAllPresenterViewControllers_dismissesAllPresentedViewControllers() {
        
        class MockViewController: UIViewController {
            
            var name:String?
            var presentedViewControllerResult:UIViewController?
            var dismissBlock:(()->())?
            var dismissed:Bool = false
            
            override var presentedViewController: UIViewController? {
                return presentedViewControllerResult
            }
            
            override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
                dismissed = true
                dismissBlock?()
                completion?()
            }
            
        }
        
        let viewController1 = MockViewController()
        let viewController2 = MockViewController()
        let viewController3 = MockViewController()
        
        viewController1.dismissBlock = { viewController2.presentedViewControllerResult = nil }
        
        viewController2.presentedViewControllerResult = viewController1
        viewController2.dismissBlock = { viewController3.presentedViewControllerResult = nil }
        
        viewController3.presentedViewControllerResult = viewController2
        
        let exp   = expectation(description: "Block need to be invoked after dismissing all presented view controllers")
        let block = { exp.fulfill() }
        viewController3.dismissAllPresentedViewControllers(completionBlock: block)
        waitForExpectations(timeout: 0) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else {
                XCTAssertTrue(viewController1.dismissed)
                XCTAssertTrue(viewController2.dismissed)
                XCTAssertFalse(viewController3.dismissed)
            }
        }
    }
    
    // MARK: - visible
    
    func testVisible_selfIsViewControler() {
        let viewController = UIViewController()
        XCTAssertEqual(viewController.visible, viewController)
    }
    
    func testVisible_selfIsNavigationController() {
        let viewController       = UIViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        XCTAssertEqual(navigationController.visible, viewController)
    }
    
    func testVisible_selfIsTabBarController() {
        let viewController   = UIViewController()
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [viewController]
        XCTAssertEqual(tabBarController.visible, viewController)
    }
    
    func testVisible_selfIsViewControllerInsideTabBarControllerInsideNavigationController() {
        let viewController = UIViewController()
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [UINavigationController(rootViewController: viewController)]
        let rootNavigationController = UINavigationController(rootViewController: tabBarController)
        XCTAssertEqual(rootNavigationController.visible, viewController)
    }
    
}
