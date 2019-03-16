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
    var mockPopNavigationController:MockPopNavigationController!
    var viewController:UIViewController!
    
    // MARK: - Setup
    
    override func setUp() {
        mockNavigationController    = MockNavigationController()
        mockPopNavigationController = MockPopNavigationController()
        viewController  = UIViewController()
    }
    
    // MARK: - PushPopFlowTransition
    
    func testPushAndPopTransition_defaultAlwaysReturnsTheSameObject() {
        let default1 = PushPopFlowTransition.default
        let default2 = PushPopFlowTransition.default
        XCTAssertTrue(default1 === default2)
    }
    
    func testPushAndPopTransition_forwardTransitionUsesPush_withoutAnimation() {
        let transition = PushPopFlowTransition.default
        let exp        = expectation(description: "Block need to be invoked after pushing view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performForwardTransition(animated: false, completion: completion)
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
        let transition = PushPopFlowTransition.default
        let exp        = expectation(description: "Block need to be invoked after pushing view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performForwardTransition(animated: true, completion: completion)
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
        let transition = PushPopFlowTransition.default
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performBackwardTransition(animated: false, completion: completion)
        
        mockPopNavigationController.viewControllers = [viewController]
        
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertFalse(mockPopNavigationController.popViewControllerParams ?? true)
    }
    
    func testPushAndPopTransition_backwardTransitionUsesPop_animated() {
        let transition = PushPopFlowTransition.default
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performBackwardTransition(animated: true, completion: completion)
        
        mockPopNavigationController.viewControllers = [viewController]
        
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertTrue(mockPopNavigationController.popViewControllerParams ?? false)
    }
    
    // MARK: - ModalFlowTransition
    
    func testModalTransition_forwardTransitionPresentsViewController_navigationControllerIsNil_withoutAnimation() {
        let transition = ModalFlowTransition()
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performForwardTransition(animated: false, completion: completion)
        transitionBlock(mockNavigationController, viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(mockNavigationController.presentViewControllerParams?.0, viewController)
        XCTAssertFalse(mockNavigationController.presentViewControllerParams?.1 ?? true)
    }
    
    func testModalTransition_forwardTransitionPresentsViewController_navigationControllerIsNil_animated() {
        let transition = ModalFlowTransition()
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performForwardTransition(animated: true, completion: completion)
        transitionBlock(mockNavigationController, viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(mockNavigationController.presentViewControllerParams?.0, viewController)
        XCTAssertTrue(mockNavigationController.presentViewControllerParams?.1 ?? false)
    }
    
    func testModalTransition_forwardTransitionPresentsViewController_navigationControllerIsNotNil_withoutAnimation() {
        let transition = ModalFlowTransition()
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performForwardTransition(animated: false, completion: completion)
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
        let transition = ModalFlowTransition()
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performForwardTransition(animated: true, completion: completion)
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
        let transition = ModalFlowTransition()
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performBackwardTransition(animated: false, completion: completion)
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
        let transition = ModalFlowTransition()
        let exp        = expectation(description: "Block need to be invoked after poping view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performBackwardTransition(animated: true, completion: completion)
        let viewController  = MockViewController()
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertTrue(viewController.dismissParams ?? false)
    }
    
    // MARK: - DefaultModalFlowTransition
    
    func testDefaultModalTransition_defaultAlwaysReturnsTheSameObject() {
        let default1 = DefaultModalFlowTransition.default
        let default2 = DefaultModalFlowTransition.default
        XCTAssertTrue(default1 === default2)
    }
    
    // MARK: - TabBarAppFlowControllerTransition
    
    func testTabBarTransition_defaultAlwaysReturnsTheSameObject() {
        let default1 = DefaultTabBarFlowTransition.default
        let default2 = DefaultTabBarFlowTransition.default
        XCTAssertTrue(default1 === default2)
    }
    
    func testTabBarTransition_forwardTransitionChangesSelectedIndexForExistingViewController() {
        let transition = DefaultTabBarFlowTransition.default
        let exp        = expectation(description: "Block need to be invoked after displaying view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock      = transition.performForwardTransition(animated: true, completion: completion)
        let tab1ViewController   = UIViewController()
        let tab2ViewController   = CustomViewController()
        let tabBarController     = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: tab1ViewController),
            UINavigationController(rootViewController: tab2ViewController)
        ]
        
        XCTAssertEqual(tabBarController.selectedIndex, 0)
        
        transitionBlock(tab2ViewController.navigationController!, tab2ViewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(tabBarController.selectedIndex, 1)
    }
    
    func testTabBarTransition_forwardTransitionWontChangeIndexIfViewControllerDoesntExists() {
        let transition = DefaultTabBarFlowTransition.default
        let exp        = expectation(description: "Block need to be invoked after displaying view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock      = transition.performForwardTransition(animated: true, completion: completion)
        let tab1ViewController   = UIViewController()
        let tab2ViewController   = CustomViewController()
        let wrongViewController  = AnotherViewController()
        let tabBarController     = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: tab1ViewController),
            UINavigationController(rootViewController: tab2ViewController)
        ]
        
        XCTAssertEqual(tabBarController.selectedIndex, 0)
        
        transitionBlock(UINavigationController(), wrongViewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(tabBarController.selectedIndex, 0)
    }
    
    func testTabBarTransition_forwardTransitionWontChangeIndexIfTopViewControllerIsNotTabBarController() {
        let transition = DefaultTabBarFlowTransition.default
        let exp        = expectation(description: "Block need to be invoked after displaying view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock      = transition.performForwardTransition(animated: true, completion: completion)
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
        let transition = DefaultTabBarFlowTransition.default
        let exp        = expectation(description: "Block need to be invoked after displaying view controller")
        let completion = {
            exp.fulfill()
        }
        let transitionBlock = transition.performBackwardTransition(animated: true, completion: completion)
        transitionBlock(viewController)
        
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
