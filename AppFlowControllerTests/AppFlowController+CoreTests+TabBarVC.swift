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
    
    func newTabBar(_ name:String = "tab_page") -> FlowPathComponent {
        return FlowPathComponent(
            name: name,
            viewControllerInit: UITabBarController.init,
            viewControllerType: UITabBarController.self
        )
    }
    
    // MARK: - current page
    
    func testCurrentPageForTabVC_tabPageIsActive() {
        prepareFlowController()
        let tab = TabBarFlowTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[2][2],
                animated: false
            )
            XCTAssertEqual(flowController.currentPathComponent, pages[2][2])
            let tabBarViewControllers = flowController.rootNavigationController?.visibleViewController as? UITabBarController
            XCTAssertEqual(tabBarViewControllers?.viewControllers?.count ?? 0, 2)
        } catch _ {
            XCTFail()
        }
    }
 
    func testShow_displayTabBarController_shouldActiveFirstPage() {
        prepareFlowController()
        let tab = TabBarFlowTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[2][1],
                animated: false
            )
            XCTAssertEqual(flowController.currentPathComponent, pages[0][2])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_changningSelectedTab() {
        prepareFlowController()
        let tab = TabBarFlowTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[2][2],
                animated: false
            )
            try flowController.show(
                pages[0][2],
                animated: false
            )
            XCTAssertEqual(flowController.currentPathComponent, pages[0][2])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_goingBackFromTabBarController() {
        prepareFlowController()
        let tab = TabBarFlowTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[2][2],
                animated: false
            )
            try flowController.show(
                pages[0][0],
                animated: false
            )
            XCTAssertEqual(flowController.currentPathComponent, pages[0][0])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_regularPageFromTabBarController() {
        prepareFlowController()
        let tab = TabBarFlowTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[1][2],
                animated: false
            )
            XCTAssertEqual(flowController.currentPathComponent, pages[1][2])
        } catch _ {
            XCTFail()
        }

    }
    
}
