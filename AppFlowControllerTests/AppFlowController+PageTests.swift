//
//  AppFlowController+PageTests.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 21.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_PageTests: XCTestCase {
 
    // MARK: - Helpers
    
    class CustomViewController: UIViewController {}
    
    class FakeStoryboard: UIStoryboard {
        
        var lastIdentifier:String?
        
        override func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
            lastIdentifier = identifier
            return CustomViewController()
        }
        
    }
    
    // MARK: - Init
    
    func testInit_assignsAllPropertiesCorrectlyAndSupportVariantsIsFalseByDefault() {
        let vc   = UIViewController()
        let page = AppFlowControllerPage(name: "Name", viewControllerBlock: { vc }, viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertFalse(page.supportVariants)
        XCTAssertEqual(page.viewControllerBlock(), vc)
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
    }
    
    func testInit_assignsAllPropertiesCorrectly() {
        let vc   = UIViewController()
        let page = AppFlowControllerPage(name: "Name", supportVariants: true, viewControllerBlock: { vc }, viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertTrue(page.supportVariants)
        XCTAssertEqual(page.viewControllerBlock(), vc)
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
    }
    
    func testInit_getsCorrectViewControllerUsingStoryboardAndVCIdentifier_supportVariantsShouldBeFalseByDefault() {
        let storyboard = FakeStoryboard()
        let page       = AppFlowControllerPage(name: "Name", storyboardName: "TestStoryboard", storyboardInitBlock: { _ in storyboard }, viewControllerIdentifier: "TestViewController", viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertFalse(page.supportVariants)
        XCTAssertTrue(page.viewControllerBlock().isKind(of: CustomViewController.self))
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
        XCTAssertEqual(storyboard.lastIdentifier, "TestViewController")
    }
    
    func testInit_getsCorrectViewControllerUsingStoryboardAndVCIdentifier() {
        let storyboard = FakeStoryboard()
        let page       = AppFlowControllerPage(name: "Name", supportVariants: true, storyboardName: "TestStoryboard", storyboardInitBlock: { _ in storyboard }, viewControllerIdentifier: "TestViewController", viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertTrue(page.supportVariants)
        XCTAssertTrue(page.viewControllerBlock().isKind(of: CustomViewController.self))
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
        XCTAssertEqual(storyboard.lastIdentifier, "TestViewController")
    }
    
    func testInit_getsCorrectViewControllerUsingStoryboard_supportVariantsShouldBeFalseByDefault() {
        let storyboard = FakeStoryboard()
        let page       = AppFlowControllerPage(name: "Name", storyboardName: "TestStoryboard", storyboardInitBlock: { _ in storyboard }, viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertFalse(page.supportVariants)
        XCTAssertTrue(page.viewControllerBlock().isKind(of: CustomViewController.self))
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
        XCTAssertEqual(storyboard.lastIdentifier, "CustomViewController")
    }
    
    func testInit_getsCorrectViewControllerUsingStoryboard() {
        let storyboard = FakeStoryboard()
        let page       = AppFlowControllerPage(name: "Name", supportVariants: true, storyboardName: "TestStoryboard", storyboardInitBlock: { _ in storyboard }, viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertTrue(page.supportVariants)
        XCTAssertTrue(page.viewControllerBlock().isKind(of: CustomViewController.self))
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
        XCTAssertEqual(storyboard.lastIdentifier, "CustomViewController")
    }
    
    // MARK: - Identifier
    
    func testIdentifier_containsOnlyNameWhenVariantNameIsNil() {
        let page = AppFlowControllerPage(name: "Name", viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
        XCTAssertEqual(page.identifier, "Name")
    }
    
    func testIdentifier_containsVariantAndNameWhenVariantIsNotNil() {
        var page = AppFlowControllerPage(name: "Name", viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
        page.variantName = "Variant"
        XCTAssertEqual(page.identifier, "Variant_Name")
    }
    
    // MARK: - Equatable
    
    func testEquatable_allParametersAreEqual() {
        var page1 = AppFlowControllerPage(name: "page", viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
        var page2 = AppFlowControllerPage(name: "page", viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
        
        page1.variantName = "Variant"
        page2.variantName = "Variant"
        
        page1.forwardTransition  = PushPopAppFlowControllerTransition.default
        page1.backwardTransition = PushPopAppFlowControllerTransition.default
        page2.forwardTransition  = PushPopAppFlowControllerTransition.default
        page2.backwardTransition = PushPopAppFlowControllerTransition.default
        
        XCTAssertTrue(page1 == page2)
    }
    
    func testEquatable_allParametersAreDifferent() {
        var page1 = AppFlowControllerPage(name: "page1", viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
        var page2 = AppFlowControllerPage(name: "page2", viewControllerBlock: { CustomViewController() }, viewControllerType: CustomViewController.self)
        
        page1.variantName = "Variant1"
        page2.variantName = "Variant2"
        
        page1.forwardTransition  = PushPopAppFlowControllerTransition.default
        page1.backwardTransition = PushPopAppFlowControllerTransition.default
        page2.forwardTransition  = DefaultModalAppFlowControllerTransition.default
        page2.backwardTransition = DefaultModalAppFlowControllerTransition.default
        
        XCTAssertFalse(page1 == page2)
    }
    
    func testEquatable_onlyOneParameterIsDifferent() {
        var page1 = AppFlowControllerPage(name: "page1", viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
        var page2 = AppFlowControllerPage(name: "page2", viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
        
        page1.variantName = "Variant"
        page2.variantName = "Variant"
        
        page1.forwardTransition  = PushPopAppFlowControllerTransition.default
        page1.backwardTransition = PushPopAppFlowControllerTransition.default
        page2.forwardTransition  = PushPopAppFlowControllerTransition.default
        page2.backwardTransition = PushPopAppFlowControllerTransition.default
        
        XCTAssertFalse(page1 == page2)
    }
    
}
