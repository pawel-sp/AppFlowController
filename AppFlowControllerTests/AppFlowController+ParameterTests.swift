//
//  AppFlowController+ParameterTests.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_ParameterTests: XCTestCase {

    // MARK: - Helpers
    
    func newPage(name:String) -> FlowPathComponent {
        return FlowPathComponent(
            name: name,
            viewControllerInit: UIViewController.init,
            viewControllerType: UIViewController.self
        )
    }
    
    // MARK: - Tests
    
    func testInit_variantIsNotNil() {
        let page    = newPage(name: "page")
        let variant = newPage(name: "variant")
        let value   = "value"
        let parameter = TransitionParameter(pathComponent: page, variant: variant, value: value)
        XCTAssertEqual(parameter.pathComponent, page)
        XCTAssertEqual(parameter.variant, variant)
        XCTAssertEqual(parameter.value, value)
    }
    
    func testInit_variantIsNil() {
        let page  = newPage(name: "page")
        let value = "value"
        let parameter = TransitionParameter(pathComponent: page, value: value)
        XCTAssertEqual(parameter.pathComponent, page)
        XCTAssertNil(parameter.variant)
        XCTAssertEqual(parameter.value, value)
    }
    
    func testID_variantIsNil() {
        let parameter = TransitionParameter(pathComponent: newPage(name: "page"), value: "value")
        XCTAssertEqual(parameter.identifier, "page")
    }
    
    func testID_variantIsNotNil() {
        let parameter = TransitionParameter(pathComponent: newPage(name: "page"), variant: newPage(name: "variant"), value: "value")
        XCTAssertEqual(parameter.identifier, "variant_page")
    }
    
}
