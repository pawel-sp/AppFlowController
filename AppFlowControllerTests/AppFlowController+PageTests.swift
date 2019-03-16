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
        let page = FlowPathComponent(name: "Name", viewControllerInit: { vc }, viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertFalse(page.supportVariants)
        XCTAssertEqual(page.viewControllerInit(), vc)
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
    }
    
    func testInit_assignsAllPropertiesCorrectly() {
        let vc   = UIViewController()
        let page = FlowPathComponent(name: "Name", supportVariants: true, viewControllerInit: { vc }, viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertTrue(page.supportVariants)
        XCTAssertEqual(page.viewControllerInit(), vc)
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
    }
    
    func testInit_getsCorrectViewControllerUsingStoryboardAndVCIdentifier_supportVariantsShouldBeFalseByDefault() {
        let storyboard = FakeStoryboard()
        let page       = FlowPathComponent(name: "Name", storyboardName: "TestStoryboard", storyboardInit: { _ in storyboard }, viewControllerIdentifier: "TestViewController", viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertFalse(page.supportVariants)
        XCTAssertTrue(page.viewControllerInit().isKind(of: CustomViewController.self))
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
        XCTAssertEqual(storyboard.lastIdentifier, "TestViewController")
    }
    
    func testInit_getsCorrectViewControllerUsingStoryboardAndVCIdentifier() {
        let storyboard = FakeStoryboard()
        let page       = FlowPathComponent(name: "Name", supportVariants: true, storyboardName: "TestStoryboard", storyboardInit: { _ in storyboard }, viewControllerIdentifier: "TestViewController", viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertTrue(page.supportVariants)
        XCTAssertTrue(page.viewControllerInit().isKind(of: CustomViewController.self))
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
        XCTAssertEqual(storyboard.lastIdentifier, "TestViewController")
    }
    
    func testInit_getsCorrectViewControllerUsingStoryboard_supportVariantsShouldBeFalseByDefault() {
        let storyboard = FakeStoryboard()
        let page       = FlowPathComponent(name: "Name", storyboardName: "TestStoryboard", storyboardInit: { _ in storyboard }, viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertFalse(page.supportVariants)
        XCTAssertTrue(page.viewControllerInit().isKind(of: CustomViewController.self))
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
        XCTAssertEqual(storyboard.lastIdentifier, "CustomViewController")
    }
    
    func testInit_getsCorrectViewControllerUsingStoryboard() {
        let storyboard = FakeStoryboard()
        let page       = FlowPathComponent(name: "Name", supportVariants: true, storyboardName: "TestStoryboard", storyboardInit: { _ in storyboard }, viewControllerType: CustomViewController.self)
        XCTAssertEqual(page.name, "Name")
        XCTAssertTrue(page.supportVariants)
        XCTAssertTrue(page.viewControllerInit().isKind(of: CustomViewController.self))
        XCTAssertTrue(page.viewControllerType.isEqual(CustomViewController.self))
        XCTAssertEqual(storyboard.lastIdentifier, "CustomViewController")
    }
    
    // MARK: - Identifier
    
    func testIdentifier_containsOnlyNameWhenVariantNameIsNil() {
        let page = FlowPathComponent(name: "Name", viewControllerInit: { UIViewController() }, viewControllerType: UIViewController.self)
        XCTAssertEqual(page.identifier, "Name")
    }
    
    func testIdentifier_containsVariantAndNameWhenVariantIsNotNil() {
        var page = FlowPathComponent(name: "Name", viewControllerInit: { UIViewController() }, viewControllerType: UIViewController.self)
        page.variantName = "Variant"
        XCTAssertEqual(page.identifier, "Variant_Name")
    }
    
    // MARK: - Equatable
    
    func testEquatable_allParametersAreEqual() {
        var page1 = FlowPathComponent(name: "page", viewControllerInit: { UIViewController() }, viewControllerType: UIViewController.self)
        var page2 = FlowPathComponent(name: "page", viewControllerInit: { UIViewController() }, viewControllerType: UIViewController.self)
        
        page1.variantName = "Variant"
        page2.variantName = "Variant"
        
        page1.forwardTransition  = PushPopFlowTransition.default
        page1.backwardTransition = PushPopFlowTransition.default
        page2.forwardTransition  = PushPopFlowTransition.default
        page2.backwardTransition = PushPopFlowTransition.default
        
        XCTAssertTrue(page1 == page2)
    }
    
    func testEquatable_allParametersAreDifferent() {
        var page1 = FlowPathComponent(name: "page1", viewControllerInit: { UIViewController() }, viewControllerType: UIViewController.self)
        var page2 = FlowPathComponent(name: "page2", viewControllerInit: { CustomViewController() }, viewControllerType: CustomViewController.self)
        
        page1.variantName = "Variant1"
        page2.variantName = "Variant2"
        
        page1.forwardTransition  = PushPopFlowTransition.default
        page1.backwardTransition = PushPopFlowTransition.default
        page2.forwardTransition  = DefaultModalFlowTransition.default
        page2.backwardTransition = DefaultModalFlowTransition.default
        
        XCTAssertFalse(page1 == page2)
    }
    
    func testEquatable_onlyOneParameterIsDifferent() {
        var page1 = FlowPathComponent(name: "page1", viewControllerInit: { UIViewController() }, viewControllerType: UIViewController.self)
        var page2 = FlowPathComponent(name: "page2", viewControllerInit: { UIViewController() }, viewControllerType: UIViewController.self)
        
        page1.variantName = "Variant"
        page2.variantName = "Variant"
        
        page1.forwardTransition  = PushPopFlowTransition.default
        page1.backwardTransition = PushPopFlowTransition.default
        page2.forwardTransition  = PushPopFlowTransition.default
        page2.backwardTransition = PushPopFlowTransition.default
        
        XCTAssertFalse(page1 == page2)
    }
    
}
