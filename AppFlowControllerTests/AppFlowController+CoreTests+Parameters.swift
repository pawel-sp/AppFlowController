//
//  AppFlowController+CoreTests+Parameters.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 26.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {

    // MARK: - currentPathParameter
    
    func testParameterForCurrentPage_thereIsNoCurrentPage() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            XCTAssertNil(flowController.currentPathParameter)
        } catch _ {
            XCTFail()
        }
    }
    
    func testParameterForCurrentPage_pageDoesntHaveRegisteredParameter() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[1])
            XCTAssertNil(flowController.currentPathParameter)
        } catch _ {
            XCTFail()
        }
    }
    
    func testParameterForCurrentPage_pageHasRegisteredParameter_withoutVariant() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[1],
                parameters: [
                    TransitionParameter(pathComponent: pages[1], value: "par1")
                ]
            )
            XCTAssertEqual(flowController.currentPathParameter, "par1")
        } catch _ {
            XCTFail()
        }
    }
    
    func testParameterForCurrentPage_pageHasRegisteredParameter_withVariant() {
        prepareFlowController()
        let pages = newPage("1") =>> [
            newPage("2") => newPage("4", supportVariants: true),
            newPage("3") => newPage("4", supportVariants: true)
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[0][2],
                variant: pages[0][1],
                parameters: [
                    TransitionParameter(pathComponent: pages[0][2], variant: pages[0][1], value: "par")
                ],
                animated: false
            )
            XCTAssertEqual(flowController.currentPathParameter, "par")
        } catch _ {
            XCTFail()
        }
    }
    
    // MARK: - parameterForPage
    
    func testParameterForPage_missingVariant() {
        prepareFlowController()
        let pages = newPage("1") =>> [
            newPage("2") => newPage("4", supportVariants: true),
            newPage("3") => newPage("4", supportVariants: true)
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[0][2],
                variant: pages[0][1],
                parameters: [
                    TransitionParameter(pathComponent: pages[0][2], variant: pages[0][1], value: "par")
                ],
                animated: false
            )
            _ = try flowController.parameter(for: pages[0][2])
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.missingVariant(identifier: "4"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testParameterForPage_variantsNotSupported() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[0])
            _ = try flowController.parameter(for: pages[1], variant: pages[0])
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.variantNotSupported(identifier: "2"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testParameterForPage_unregisteredPath() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[0])
            _ = try flowController.parameter(for: newPage("3"))
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.unregisteredPathIdentifier(identifier: "3"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testParameterForPage_incorrectVariant() {
        prepareFlowController()
        let pages = newPage("1") =>> [
            newPage("2") => newPage("4", supportVariants: true),
            newPage("3") => newPage("4", supportVariants: true)
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[0][2],
                variant: pages[0][1],
                parameters: [
                    TransitionParameter(pathComponent: pages[0][2], variant: pages[0][1], value: "par")
                ],
                animated: false
            )
            _ = try flowController.parameter(for: pages[0][2], variant: pages[0][0])
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.unregisteredPathIdentifier(identifier: "1_4"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testParameterForPage_withoutVariant() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[1],
                parameters:[
                    TransitionParameter(pathComponent: pages[1], value: "par")
                ],
                animated: false
            )
            let par1 = try flowController.parameter(for: pages[0])
            let par2 = try flowController.parameter(for: pages[1])
            XCTAssertNil(par1)
            XCTAssertEqual(par2, "par")
        } catch _ {
            XCTFail()
        }
    }
    
    func testParameterForPage_withVariant() {
        prepareFlowController()
        let pages = newPage("1") =>> [
            newPage("2") => newPage("4", supportVariants: true),
            newPage("3") => newPage("4", supportVariants: true)
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[0][2],
                variant: pages[0][1],
                parameters: [
                    TransitionParameter(pathComponent: pages[0][2], variant: pages[0][1], value: "par")
                ],
                animated: false
            )
            let par1 = try flowController.parameter(for: pages[0][2], variant: pages[0][1])
            let par2 = try flowController.parameter(for: pages[1][2], variant: pages[1][1])
            XCTAssertEqual(par1, "par")
            XCTAssertNil(par2)
        } catch _ {
            XCTFail()
        }
    }
    
}
