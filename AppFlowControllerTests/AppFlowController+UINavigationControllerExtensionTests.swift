//
//  AppFlowController+UINavigationControllerExtensionTests
//  AppFlowControllerTests
//
//  Created by Paweł Sporysz on 20.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowControllerTests: XCTestCase {

    // MARK: - Properties
    
    var navigationController:MockNavigationController!
    
    // MARK: - Setup
    
    override func setUp() {
        navigationController = MockNavigationController()
    }
    
    // MARK: - pushViewController with completion block
    
    func testPushViewController_pushesViewControllerAnimatedWithCorrectParameters() {
        let viewController = UIViewController()
        navigationController.pushViewController(viewController, animated: true, completion: nil)
        XCTAssertEqual(navigationController.pushViewControllerParams?.0, viewController)
        XCTAssertTrue(navigationController.pushViewControllerParams?.1 ?? false)
    }
    
    func testPushViewController_pushesViewControllerWithoutAnimationWithCorrectParameters() {
        let viewController = UIViewController()
        navigationController.pushViewController(viewController, animated: false, completion: nil)
        XCTAssertEqual(navigationController.pushViewControllerParams?.0, viewController)
        XCTAssertFalse(navigationController.pushViewControllerParams?.1 ?? true)
    }
    
    func testPushViewController_invokesCompletionBlock() {
        let exp = expectation(description: "Block need to be invoked after pushing view controller")
        let block = {
            exp.fulfill()
        }
        navigationController.pushViewController(UIViewController(), animated: false, completion: block)
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    // MARK: - popViewController with completion block
    
    func testPopViewController_popsViewControllerAnimatedWithCorrectParameters() {
        navigationController.popViewController(animated: true, completion: nil)
        XCTAssertTrue(navigationController.popViewControllerParams ?? false)
    }
    
    func testPopViewController_popsViewControllerWithoutAnimationWithCorrectParameters() {
        navigationController.popViewController(animated: false, completion: nil)
        XCTAssertFalse(navigationController.popViewControllerParams ?? true)
    }
    
    func testPopViewController_invokesCompletionBlock() {
        let exp = expectation(description: "Block need to be invoked after poping view controller")
        let block = {
            exp.fulfill()
        }
        navigationController.popViewController(animated: false, completion: block)
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    // MARK: - setViewControllers with completion block
    
    func testSetViewController_setsViewControllerAnimatedWithCorrectParameters() {
        let viewControllers = [UIViewController()]
        navigationController.setViewControllers(viewControllers, animated: true, completion: nil)
        XCTAssertEqual(navigationController.setViewControllersParams?.0 ?? [], viewControllers)
        XCTAssertTrue(navigationController.setViewControllersParams?.1 ?? false)
    }
    
    func testSetViewController_setsViewControllerWithoutAnimationWithCorrectParameters() {
        let viewControllers = [UIViewController()]
        navigationController.setViewControllers(viewControllers, animated: false, completion: nil)
        XCTAssertEqual(navigationController.setViewControllersParams?.0 ?? [], viewControllers)
        XCTAssertFalse(navigationController.setViewControllersParams?.1 ?? true)
    }
    
    func testSetViewController_invokesCompletionBlock() {
        let exp   = expectation(description: "Block need to be invoked after poping view controller")
        let block = { exp.fulfill() }
        navigationController.setViewControllers([UIViewController()], animated: false, completion: block)
        waitForExpectations(timeout: 0.1) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    // MARK: - visibleNavigationController
    
    func testVisibleNavigationController_returnsSelfIfItsEmpty() {
        let navigationController = UINavigationController()
        XCTAssertEqual(navigationController.visibleNavigationController, navigationController)
    }
    
    func testVisibleNavigationController_returnsSelfIfThereAreNoAdditionalNavigationControllers() {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        XCTAssertEqual(navigationController.visibleNavigationController, navigationController)
    }
    
    func testVisibleNavigationController_returnsEmbededNavigationController() {
        let rootNavigationController  = MockNavigationController(rootViewController: UIViewController())
        let visibleViewController     = UIViewController()
        let modalNavigationController = UINavigationController(rootViewController: visibleViewController)
        rootNavigationController.visibleViewControllerResult = visibleViewController
        XCTAssertEqual(rootNavigationController.visibleNavigationController, modalNavigationController)
    }
    
}
