//
//  AppFlowController+CoreTests+TabBarVC.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 26.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {

    // MARK: - Helpers
    
    func newTabBar(_ name:String = "tab_page") -> AppFlowControllerPage {
        return AppFlowControllerPage(
            name: name,
            viewControllerBlock: { UITabBarController() },
            viewControllerType: UITabBarController.self
        )
    }
    
    // MARK: - current page
    
    func testCurrentPageForTabVC_tabPageIsActive() {
        prepareFlowController(fakeNC: true)
        let tab = TabBarAppFlowControllerTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[2][2],
                animated: false
            )
            XCTAssertEqual(flowController.currentPage(), pages[2][2])
            let tabBarViewControllers = flowController.rootNavigationController?.visibleViewController as? UITabBarController
            XCTAssertEqual(tabBarViewControllers?.viewControllers?.count ?? 0, 2)
        } catch _ {
            XCTFail()
        }
    }
 
    func testShow_displayTabBarController_shouldActiveFirstPage() {
        prepareFlowController(fakeNC: true)
        let tab = TabBarAppFlowControllerTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[2][1],
                animated: false
            )
            XCTAssertEqual(flowController.currentPage(), pages[0][2])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_changningSelectedTab() {
        prepareFlowController(fakeNC: true)
        let tab = TabBarAppFlowControllerTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[2][2],
                animated: false
            )
            try flowController.show(
                page: pages[0][2],
                animated: false
            )
            XCTAssertEqual(flowController.currentPage(), pages[0][2])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_goingBackFromTabBarController() {
        prepareFlowController(fakeNC: true)
        let tab = TabBarAppFlowControllerTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[2][2],
                animated: false
            )
            try flowController.show(
                page: pages[0][0],
                animated: false
            )
            XCTAssertEqual(flowController.currentPage(), pages[0][0])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_regularPageFromTabBarController() {
        prepareFlowController(fakeNC: true)
        let tab = TabBarAppFlowControllerTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[1][2],
                animated: false
            )
            XCTAssertEqual(flowController.currentPage(), pages[1][2])
        } catch _ {
            XCTFail()
        }

    }
    
}
