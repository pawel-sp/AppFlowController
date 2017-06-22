//
//  AppFlowController+CoreTests.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_CoreTests: XCTestCase {
    
    // MARK: - Helpers
    
    func newPage(_ name:String = "page", supportVariants:Bool = false) -> AppFlowControllerPage {
        return AppFlowControllerPage(name: name, supportVariants: supportVariants, viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
    }
    
    // MARK: - Properties
    
    var flowController:AppFlowController!
    
    // MARK: - Setup
    
    override func setUp() {
        flowController = AppFlowController()
    }
    
    // MARK: - Tests
    
    // MARK: - Init & setup
    
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
    
    // MARK: - Register
    
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
        let pages = [
            newPage("1"),
            newPage("2")
        ]
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
        let pages = [
            [
                newPage("1"),
                newPage("2")
            ],
            [
                newPage("1"),
                newPage("3")
            ]
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
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.pathNameAlreadyRegistered(name: "1"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testRegister_stepAlreadyRegistered_supportVariants() {
        let rootPage = newPage("root", supportVariants: false)
        let page1 = newPage("1", supportVariants: true)
        let page2 = newPage("2", supportVariants: false)
        let page3 = newPage("3", supportVariants: false)
        let pages = [
            [
                rootPage,
                page2,
                page1
            ],
            [
                rootPage,
                page3,
                page1
            ]
        ]
        do {
            try flowController.register(path: pages)
            let expectedRoot = PathStep(page: rootPage)
            var repeatedPage1 = page1
            var repeatedPage2 = page1
            repeatedPage1.variantName = "2"
            repeatedPage2.variantName = "3"
            expectedRoot.add(page: page2).add(page: repeatedPage1)
            expectedRoot.add(page: page3).add(page: repeatedPage2)
            XCTAssertEqual(flowController.rootPathStep, expectedRoot)
        } catch _ {
            XCTFail()
        }
    }
    
}
