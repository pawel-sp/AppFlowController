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
        
        let name: String
        
        init(name: String) {
            self.name = name
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    func newPage(_ name: String = "page", supportVariants: Bool = false) -> FlowPathComponent {
        return FlowPathComponent(
            name: name,
            supportVariants: supportVariants,
            viewControllerInit: { NameViewController(name: name) },
            viewControllerType: NameViewController.self
        )
    }
    
    func prepareFlowController() {
        let window = UIWindow()
        let navigationController = FakeNavigationController()
        flowController.prepare(for: window, rootNavigationController: navigationController)
    }
    
    // MARK: - Properties
    
    var flowController: AppFlowController!
    
    var currentVCNames: [String] {
        return (flowController.rootNavigationController?.viewControllers as? [NameViewController])?.map{ $0.name } ?? []
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
            try flowController.register(pathComponent: page)
            XCTAssertEqual(flowController.rootPathStep, PathStep(pathComponent: page))
        } catch _ {
            XCTFail()
        }
    }
    
    func testRegister_arrayOfPaths() {
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            let expectedRoot = PathStep(pathComponent: pages[0])
            expectedRoot.add(pathComponent: pages[1])
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
            try flowController.register(pathComponents: pages)
            let expectedRoot = PathStep(pathComponent: pages[0][0])
            expectedRoot.add(pathComponent: pages[0][1])
            expectedRoot.add(pathComponent: pages[1][1])
            XCTAssertEqual(flowController.rootPathStep, expectedRoot)
        } catch _ {
            XCTFail()
        }
    }
    
    func testRegister_stepAlreadyRegistered() {
        let page = newPage("1")
        do {
            try flowController.register(pathComponent: page)
            try flowController.register(pathComponent: page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.pathAlreadyRegistered(identifier: "1"))
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
        newPage3.backwardTransition = PushPopFlowTransition.default
        do {
            try flowController.register(pathComponents: [
                newPage1,
                newPage2,
                newPage3
            ])
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.missingPathStepTransition(identifier: "2"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testRegister_oneOfStepsDoesntHaveBackwardTransition() {
        let newPage1 = newPage("1")
        let newPage2 = newPage("2")
        var newPage3 = newPage("3")
        newPage3.forwardTransition = PushPopFlowTransition.default
        newPage3.backwardTransition = nil
        do {
            try flowController.register(pathComponents: [
                newPage1,
                newPage2,
                newPage3
                ])
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.missingPathStepTransition(identifier: "2"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testRegister_firstPathStepCanHaveNilTransition() {
        let newPage1 = newPage("1")
        var newPage2 = newPage("2")
        var newPage3 = newPage("3")
        newPage2.forwardTransition  = PushPopFlowTransition.default
        newPage2.backwardTransition = PushPopFlowTransition.default
        newPage3.forwardTransition  = PushPopFlowTransition.default
        newPage3.backwardTransition = PushPopFlowTransition.default
        do {
            try flowController.register(pathComponents: [
                newPage1,
                newPage2,
                newPage3
            ])
            let expectedRoot = PathStep(pathComponent: newPage1)
            expectedRoot.add(pathComponent: newPage2).add(pathComponent: newPage3)
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
            try flowController.register(pathComponents: pages)
            let expectedRoot = PathStep(pathComponent: rootPage)
            var repeatedPage1_1 = page1
            var repeatedPage1_2 = page1
            
            repeatedPage1_1.variantName = "2"
            repeatedPage1_2.variantName = "3"
            
            repeatedPage1_1.forwardTransition  = PushPopFlowTransition.default
            repeatedPage1_1.backwardTransition = PushPopFlowTransition.default
            repeatedPage1_2.forwardTransition  = PushPopFlowTransition.default
            repeatedPage1_2.backwardTransition = PushPopFlowTransition.default
            
            page2.forwardTransition  = PushPopFlowTransition.default
            page2.backwardTransition = PushPopFlowTransition.default
            page3.forwardTransition  = PushPopFlowTransition.default
            page3.backwardTransition = PushPopFlowTransition.default
            
            expectedRoot.add(pathComponent: page2).add(pathComponent: repeatedPage1_1)
            expectedRoot.add(pathComponent: page3).add(pathComponent: repeatedPage1_2)
            
            XCTAssertEqual(flowController.rootPathStep, expectedRoot)
        } catch _ {
            XCTFail()
        }
    }

}
