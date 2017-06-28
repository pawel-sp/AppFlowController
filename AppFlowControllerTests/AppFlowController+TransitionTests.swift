//
//  AppFlowController+TransitionTests.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 21.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_TransitionTests: XCTestCase {
    
    // MARK: - Helpers
    
    class CustomNavigationBar:UINavigationBar {}
    class CustomViewController:UIViewController {}
    class AnotherViewController:UIViewController {}
    
    // MARK: - Properties
    
    var mockNavigationController:MockNavigationController!
    var viewController:UIViewController!
    
    // MARK: - Setup
    
    override func setUp() {
        mockNavigationController = MockNavigationController()
        viewController  = UIViewController()
    }
    
    // MARK: - PushPopAppFlowControllerTransition
    
    func testPushAndPopTransition_defaultAlwaysReturnsTheSameObject() {
        let default1 = PushPopAppFlowControllerTransition.default
        let default2 = PushPopAppFlowControllerTransition.default
        XCTAssertEqual(default1, default2)
    }
    
    func testPushAndPopTransition_forwardTransitionUsesPush_withoutAnimation() {
        let transition = PushPopAppFlowControllerTransition.default
        let exp        = expectation(description: "Block need to be invoked after pushing view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.forwardTransitionBlock(animated: false, completionBlock: completionBlock)
        transitionBlock(mockNavigationController, viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(mockNavigationController.pushViewControllerParams?.0, viewController)
        XCTAssertFalse(mockNavigationController.pushViewControllerParams?.1 ?? true)
    }
    
    func testPushAndPopTransition_forwardTransitionUsesPush_animated() {
        let transition = PushPopAppFlowControllerTransition.default
        let exp        = expectation(description: "Block need to be invoked after pushing view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.forwardTransitionBlock(animated: true, completionBlock: completionBlock)
        transitionBlock(mockNavigationController, viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(mockNavigationController.pushViewControllerParams?.0, viewController)
        XCTAssertTrue(mockNavigationController.pushViewControllerParams?.1 ?? false)
    }
    
    func testPushAndPopTransition_backwardTransitionUsesPop_withoutAnimation() {
        let transition = PushPopAppFlowControllerTransition.default
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.backwardTransitionBlock(animated: false, completionBlock: completionBlock)
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertFalse(mockNavigationController.popViewControllerParams ?? true)
    }
    
    func testPushAndPopTransition_backwardTransitionUsesPop_animated() {
        let transition = PushPopAppFlowControllerTransition.default
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.backwardTransitionBlock(animated: true, completionBlock: completionBlock)
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertTrue(mockNavigationController.popViewControllerParams ?? false)
    }
    
    // MARK: - ModalAppFlowControllerTransition
    
    func testModalTransition_initAssignsParametersCorrectly() {
        let transition = ModalAppFlowControllerTransition(navigationBarClass: CustomNavigationBar.self)
        XCTAssertTrue(transition.navigationBarClass == CustomNavigationBar.self)
    }
    
    func testModalTransition_initAssignNilToNavigationBarClassByDefault() {
        let transition = ModalAppFlowControllerTransition()
        XCTAssertNil(transition.navigationBarClass)
    }
    
    func testModalTransition_forwardTransitionPresentsViewController_navigationControllerIsNil_withoutAnimation() {
        let transition = ModalAppFlowControllerTransition(navigationBarClass: CustomNavigationBar.self)
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.forwardTransitionBlock(animated: false, completionBlock: completionBlock)
        transitionBlock(mockNavigationController, viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertTrue(mockNavigationController.presentViewControllerParams?.0 is UINavigationController)
        XCTAssertTrue((mockNavigationController.presentViewControllerParams?.0 as? UINavigationController)?.navigationBar.isKind(of: CustomNavigationBar.self) ?? false)
        XCTAssertEqual((mockNavigationController.presentViewControllerParams?.0 as? UINavigationController)?.viewControllers.first, viewController)
        XCTAssertFalse(mockNavigationController.presentViewControllerParams?.1 ?? true)
    }
    
    func testModalTransition_forwardTransitionPresentsViewController_navigationControllerIsNil_animated() {
        let transition = ModalAppFlowControllerTransition(navigationBarClass: CustomNavigationBar.self)
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.forwardTransitionBlock(animated: true, completionBlock: completionBlock)
        transitionBlock(mockNavigationController, viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertTrue(mockNavigationController.presentViewControllerParams?.0 is UINavigationController)
        XCTAssertTrue((mockNavigationController.presentViewControllerParams?.0 as? UINavigationController)?.navigationBar.isKind(of: CustomNavigationBar.self) ?? false)
        XCTAssertEqual((mockNavigationController.presentViewControllerParams?.0 as? UINavigationController)?.viewControllers.first, viewController)
        XCTAssertTrue(mockNavigationController.presentViewControllerParams?.1 ?? false)
    }
    
    func testModalTransition_forwardTransitionPresentsViewController_navigationControllerIsNotNil_withoutAnimation() {
        let transition = ModalAppFlowControllerTransition(navigationBarClass: CustomNavigationBar.self)
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.forwardTransitionBlock(animated: false, completionBlock: completionBlock)
        let _ = UINavigationController(rootViewController: viewController)
        transitionBlock(mockNavigationController, viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertFalse(mockNavigationController.presentViewControllerParams?.0 is UINavigationController)
        XCTAssertFalse((mockNavigationController.presentViewControllerParams?.0 as? UINavigationController)?.navigationBar.isKind(of: CustomNavigationBar.self) ?? false)
        XCTAssertEqual(mockNavigationController.presentViewControllerParams?.0, viewController)
        XCTAssertFalse(mockNavigationController.presentViewControllerParams?.1 ?? true)
    }
    
    func testModalTransition_forwardTransitionPresentsViewController_navigationControllerIsNotNil_animated() {
        let transition = ModalAppFlowControllerTransition(navigationBarClass: CustomNavigationBar.self)
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.forwardTransitionBlock(animated: true, completionBlock: completionBlock)
        let _ = UINavigationController(rootViewController: viewController)
        transitionBlock(mockNavigationController, viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertFalse(mockNavigationController.presentViewControllerParams?.0 is UINavigationController)
        XCTAssertFalse((mockNavigationController.presentViewControllerParams?.0 as? UINavigationController)?.navigationBar.isKind(of: CustomNavigationBar.self) ?? false)
        XCTAssertEqual(mockNavigationController.presentViewControllerParams?.0, viewController)
        XCTAssertTrue(mockNavigationController.presentViewControllerParams?.1 ?? false)
    }
    
    func testModalTransition_backwardTransitionDismissViewController_withoutAnimation() {
        let transition = ModalAppFlowControllerTransition(navigationBarClass: CustomNavigationBar.self)
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.backwardTransitionBlock(animated: false, completionBlock: completionBlock)
        let viewController  = MockViewController()
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertFalse(viewController.dismissParams ?? true)
    }
    
    func testModalTransition_backwardTransitionDismissViewController_animated() {
        let transition = ModalAppFlowControllerTransition(navigationBarClass: CustomNavigationBar.self)
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.backwardTransitionBlock(animated: true, completionBlock: completionBlock)
        let viewController  = MockViewController()
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertTrue(viewController.dismissParams ?? false)
    }
    
    // MARK: - DefaultModalAppFlowControllerTransition
    
    func testDefaultModalTransition_defaultAlwaysReturnsTheSameObject() {
        let default1 = DefaultModalAppFlowControllerTransition.default
        let default2 = DefaultModalAppFlowControllerTransition.default
        XCTAssertEqual(default1, default2)
    }
    
    // MARK: - TabBarAppFlowControllerTransition
    
    func testTabBarTransition_defaultAlwaysReturnsTheSameObject() {
        let default1 = TabBarAppFlowControllerTransition.default
        let default2 = TabBarAppFlowControllerTransition.default
        XCTAssertEqual(default1, default2)
    }
    
    func testTabBarTransition_forwardTransitionChangesSelectedIndexForExistingViewController() {
        let transition = TabBarAppFlowControllerTransition.default
        let exp        = expectation(description: "Block need to be invoked after displaying view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock      = transition.forwardTransitionBlock(animated: true, completionBlock: completionBlock)
        let navigationController = StubNavigationController()
        let tab1ViewController   = UIViewController()
        let tab2ViewController   = CustomViewController()
        let tabBarController     = UITabBarController()
        tabBarController.viewControllers = [
            tab1ViewController,
            tab2ViewController
        ]
        navigationController.topViewControllerResult = tabBarController
        
        XCTAssertEqual(tabBarController.selectedIndex, 0)
        
        transitionBlock(navigationController, tab2ViewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(tabBarController.selectedIndex, 1)
    }
    
    func testTabBarTransition_forwardTransitionWontChangeIndexIfViewControllerDoesntExists() {
        let transition = TabBarAppFlowControllerTransition.default
        let exp        = expectation(description: "Block need to be invoked after displaying view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock      = transition.forwardTransitionBlock(animated: true, completionBlock: completionBlock)
        let navigationController = StubNavigationController()
        let tab1ViewController   = UIViewController()
        let tab2ViewController   = CustomViewController()
        let wrongViewController  = AnotherViewController()
        let tabBarController     = UITabBarController()
        tabBarController.viewControllers = [
            tab1ViewController,
            tab2ViewController
        ]
        navigationController.topViewControllerResult = tabBarController
        
        XCTAssertEqual(tabBarController.selectedIndex, 0)
        
        transitionBlock(navigationController, wrongViewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(tabBarController.selectedIndex, 0)
    }
    
    func testTabBarTransition_forwardTransitionWontChangeIndexIfTopViewControllerIsNotTabBarController() {
        let transition = TabBarAppFlowControllerTransition.default
        let exp        = expectation(description: "Block need to be invoked after displaying view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock      = transition.forwardTransitionBlock(animated: true, completionBlock: completionBlock)
        let navigationController = StubNavigationController()
        let tab1ViewController   = UIViewController()
        let tab2ViewController   = CustomViewController()
        let wrongViewController  = AnotherViewController()
        let tabBarController     = UITabBarController()
        tabBarController.viewControllers = [
            tab1ViewController,
            tab2ViewController
        ]
        
        XCTAssertEqual(tabBarController.selectedIndex, 0)
        
        transitionBlock(navigationController, wrongViewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(tabBarController.selectedIndex, 0)
    }
    
    func testTabBarTransition_backwardTransitionInvokesCompletion() {
        let transition = TabBarAppFlowControllerTransition.default
        let exp        = expectation(description: "Block need to be invoked after displaying view controller")
        let completionBlock = {
            exp.fulfill()
        }
        let transitionBlock = transition.backwardTransitionBlock(animated: true, completionBlock: completionBlock)
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
