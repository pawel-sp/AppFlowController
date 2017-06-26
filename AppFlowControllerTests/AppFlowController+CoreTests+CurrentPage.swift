//
//  AppFlowController+CoreTests+CurrentPage.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 26.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {
    
    func testCurrentPage_missingPrepareMethodInvokation() {
        XCTAssertNil(flowController.currentPage())
    }
    
    func testCurrentPage_rootNavigationControllerIsEmpty() {
        prepareFlowController()
        XCTAssertNil(flowController.currentPage())
    }
    
    func testCurrentPage_thereIsNoShownPage() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(path: pages)
            XCTAssertNil(flowController.currentPage())
        } catch _ {
            XCTFail()
        }
    }
    
    func testCurrentPage_visibleViewControllerIsNotRegistered() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(path: pages)
            flowController.rootNavigationController?.viewControllers = [UIViewController()]
            XCTAssertNil(flowController.currentPage())
        } catch _ {
            XCTFail()
        }
    }
    
    func testCurrentPage_withoutVariant() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[1])
            XCTAssertEqual(flowController.currentPage(), pages[1])
        } catch _ {
            XCTFail()
        }
    }
    
    func testCurrentPage_withVariant() {
        prepareFlowController()
        let pages = newPage("1") =>> [
            newPage("2") => newPage("4", supportVariants: true),
            newPage("3") => newPage("4", supportVariants: true)
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[0][2], variant: pages[0][1], animated: false)
            var expectedPage = pages[0][2]
            expectedPage.variantName = "2"
            XCTAssertEqual(flowController.currentPage(), expectedPage)
        } catch _ {
            XCTFail()
        }
    }
    
}
