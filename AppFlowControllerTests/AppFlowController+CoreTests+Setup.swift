//
//  AppFlowController+CoreTests+Setup.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_CoreTests: XCTestCase {
    
    // MARK: - Helpers
    
    class NameViewController: UIViewController {
        
        let name:String
        
        init(name:String) {
            self.name = name
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    func newPage(_ name:String = "page", supportVariants:Bool = false) -> AppFlowControllerPage {
        return AppFlowControllerPage(
            name: name,
            supportVariants: supportVariants,
            viewControllerBlock: { NameViewController(name: name) },
            viewControllerType: NameViewController.self
        )
    }
    
    // sometimes fake navigation controller is necessary to check vc's stack
    func prepareFlowController(fakeNC:Bool = false) {
        let window = UIWindow()
        let navigationController = fakeNC ? FakeNavigationController() : UINavigationController()
        flowController.prepare(for: window, rootNavigationController: navigationController)
    }
    
    // MARK: - Properties
    
    var flowController:AppFlowController!
    
    var currentVCNames:[String] {
        return (flowController.rootNavigationController?.viewControllers as? [NameViewController])?.map({ $0.name }) ?? []
    }
    
    // MARK: - Setup
    
    override func setUp() {
        flowController = AppFlowController()
    }
    
    // MARK: - Tests
    
    func testShared_shouldBeAlwaysTheSameObject() {
        let shared1 = AppFlowController.shared
        let shared2 = AppFlowController.shared
        XCTAssertTrue(shared1 === shared2)
    }
    
    func testPrepare() {
        let window = UIWindow()
        let navigationController = UINavigationController()
        flowController.prepare(for: window, rootNavigationController: navigationController)
        XCTAssertEqual(flowController.rootNavigationController, navigationController)
        XCTAssertEqual(window.rootViewController, navigationController)
    }
    
    func testRegister_path() {
        let page = newPage()
        do {
            try flowController.register(path: page)
            XCTAssertEqual(flowController.rootPathStep, PathStep(page: page))
        } catch _ {
            XCTFail()
        }
    }
    
    func testRegister_arrayOfPaths() {
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(path: pages)
            let expectedRoot = PathStep(page: pages[0])
            expectedRoot.add(page: pages[1])
            XCTAssertEqual(flowController.rootPathStep, expectedRoot)
        } catch _ {
            XCTFail()
        }
    }
    
    func testRegister_arrayOfPathArrays() {
        let pages = newPage("1") =>> [
            newPage("2"),
            newPage("3")
        ]
        do {
            try flowController.register(path: pages)
            let expectedRoot = PathStep(page: pages[0][0])
            expectedRoot.add(page: pages[0][1])
            expectedRoot.add(page: pages[1][1])
            XCTAssertEqual(flowController.rootPathStep, expectedRoot)
        } catch _ {
            XCTFail()
        }
    }
    
    func testRegister_stepAlreadyRegistered() {
        let page = newPage("1")
        do {
            try flowController.register(path: page)
            try flowController.register(path: page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.pathAlreadyRegistered(identifier: "1"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testRegister_oneOfStepsDoesntHaveForwardTransition() {
        let newPage1 = newPage("1")
        let newPage2 = newPage("2")
        var newPage3 = newPage("3")
        newPage3.forwardTransition  = nil
        newPage3.backwardTransition = PushPopAppFlowControllerTransition.default
        do {
            try flowController.register(path: [
                newPage1,
                newPage2,
                newPage3
            ])
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.missingPathStepTransition(identifier: "2"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testRegister_oneOfStepsDoesntHaveBackwardTransition() {
        let newPage1 = newPage("1")
        let newPage2 = newPage("2")
        var newPage3 = newPage("3")
        newPage3.forwardTransition  = PushPopAppFlowControllerTransition.default
        newPage3.backwardTransition = nil
        do {
            try flowController.register(path: [
                newPage1,
                newPage2,
                newPage3
                ])
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.missingPathStepTransition(identifier: "2"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testRegister_firstPathStepCanHaveNilTransition() {
        let newPage1 = newPage("1")
        var newPage2 = newPage("2")
        var newPage3 = newPage("3")
        newPage2.forwardTransition  = PushPopAppFlowControllerTransition.default
        newPage2.backwardTransition = PushPopAppFlowControllerTransition.default
        newPage3.forwardTransition  = PushPopAppFlowControllerTransition.default
        newPage3.backwardTransition = PushPopAppFlowControllerTransition.default
        do {
            try flowController.register(path: [
                newPage1,
                newPage2,
                newPage3
            ])
            let expectedRoot = PathStep(page: newPage1)
            expectedRoot.add(page: newPage2).add(page: newPage3)
            XCTAssertEqual(flowController.rootPathStep, expectedRoot)
        } catch _ {
            XCTFail()
        }
    }
    
    func testRegister_stepAlreadyRegistered_supportVariants() {
        let rootPage = newPage("root", supportVariants: false)
        let page1 = newPage("1", supportVariants: true)
        var page2 = newPage("2", supportVariants: false)
        var page3 = newPage("3", supportVariants: false)
        let pages = rootPage =>> [
            page2 => page1,
            page3 => page1
        ]
        do {
            try flowController.register(path: pages)
            let expectedRoot = PathStep(page: rootPage)
            var repeatedPage1_1 = page1
            var repeatedPage1_2 = page1
            
            repeatedPage1_1.variantName = "2"
            repeatedPage1_2.variantName = "3"
            
            repeatedPage1_1.forwardTransition  = PushPopAppFlowControllerTransition.default
            repeatedPage1_1.backwardTransition = PushPopAppFlowControllerTransition.default
            repeatedPage1_2.forwardTransition  = PushPopAppFlowControllerTransition.default
            repeatedPage1_2.backwardTransition = PushPopAppFlowControllerTransition.default
            
            page2.forwardTransition  = PushPopAppFlowControllerTransition.default
            page2.backwardTransition = PushPopAppFlowControllerTransition.default
            page3.forwardTransition  = PushPopAppFlowControllerTransition.default
            page3.backwardTransition = PushPopAppFlowControllerTransition.default
            
            expectedRoot.add(page: page2).add(page: repeatedPage1_1)
            expectedRoot.add(page: page3).add(page: repeatedPage1_2)
            
            XCTAssertEqual(flowController.rootPathStep, expectedRoot)
        } catch _ {
            XCTFail()
        }
    }

}
