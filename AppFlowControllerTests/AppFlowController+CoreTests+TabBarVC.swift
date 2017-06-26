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
    
    class Tab1ViewController: UIViewController {}
    class Tab2ViewController: UIViewController {}
    
    func newTabBar(_ name:String = "tab_page") -> AppFlowControllerPage {
        return AppFlowControllerPage(
            name: name,
            viewControllerBlock: { UITabBarController() },
            viewControllerType: UITabBarController.self
        )
    }
    
    func newTabPage(_ name:String, vcClass:UIViewController.Type) -> AppFlowControllerPage {
        return AppFlowControllerPage(
            name: name,
            viewControllerBlock: { vcClass.init() },
            viewControllerType: vcClass
        )
    }
    
    // MARK: - current page
    
    func testRegister_tabPagesWithTheSameClasses() {
        prepareFlowController(fakeNC: true)
        let tab = TabBarAppFlowControllerTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newPage("2"),
            newPage("3"),
            tab => newPage("4")
        ]
        do {
            try flowController.register(path: pages)
            XCTFail()
        }catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.tabBarPageViewControllerIncorrect)
            } else {
                XCTFail()
            }
        }
    }
    
    func testCurrentPageForTabVC_tabPageIsActive() {
        prepareFlowController(fakeNC: true)
        let tab = TabBarAppFlowControllerTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newTabPage("2", vcClass: Tab1ViewController.self),
            newPage("3"),
            tab => newTabPage("4", vcClass: Tab2ViewController.self)
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
            XCTAssertTrue(tabBarViewControllers?.viewControllers?[0].isKind(of: Tab1ViewController.self) ?? false)
            XCTAssertTrue(tabBarViewControllers?.viewControllers?[1].isKind(of: Tab2ViewController.self) ?? false)
        } catch _ {
            XCTFail()
        }
    }
 
    func testShow_displayTabBarController_shouldActiveFirstPage() {
        prepareFlowController(fakeNC: true)
        let tab = TabBarAppFlowControllerTransition()
        let pages = newPage("1") => newTabBar("tab") =>> [
            tab => newTabPage("2", vcClass: Tab1ViewController.self),
            newPage("3"),
            tab => newTabPage("4", vcClass: Tab2ViewController.self)
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
            tab => newTabPage("2", vcClass: Tab1ViewController.self),
            newPage("3"),
            tab => newTabPage("4", vcClass: Tab2ViewController.self)
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
            tab => newTabPage("2", vcClass: Tab1ViewController.self),
            newPage("3"),
            tab => newTabPage("4", vcClass: Tab2ViewController.self)
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
            tab => newTabPage("2", vcClass: Tab1ViewController.self),
            newPage("3"),
            tab => newTabPage("4", vcClass: Tab2ViewController.self)
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
