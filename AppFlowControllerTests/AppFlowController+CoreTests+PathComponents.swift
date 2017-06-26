//
//  AppFlowController+CoreTests+PathComponents.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 26.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {
    
    // MARK: - pathComponents
    
    func testPathComponents_pathInNotRegistered() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        try! flowController.register(path: pages)
        do {
            _ = try flowController.pathComponents(for: newPage("3"))
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.unregisteredPathIdentifier(identifier: "3"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testPathComponents_pathIsRegistered() {
        prepareFlowController()
        let pages = newPage("1") =>>
            [
                newPage("2"),
                newPage("3")
            ]
        try! flowController.register(path: pages)
        do {
            let paths = try flowController.pathComponents(for: pages[0][1])
            XCTAssertEqual(paths, "1/2")
        } catch _ {
            XCTFail()
        }
    }
    
    func testPathComponents_pathIsRoot() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        try! flowController.register(path: pages)
        do {
            let paths = try flowController.pathComponents(for: pages[0])
            XCTAssertEqual(paths, "1")
        } catch _ {
            XCTFail()
        }
    }
    
    func testPathComponents_variants_missingVariant() {
        prepareFlowController()
        let page  = newPage("4", supportVariants: true)
        let pages = newPage("1") =>>
            [
                newPage("2") => page,
                newPage("3") => page
            ]
        try! flowController.register(path: pages)
        do {
            _ = try flowController.pathComponents(for: page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.missingVariant(identifier: "4"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testPathComponents_variants_pageDoesntSupportVariant() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3")
        try! flowController.register(path: pages)
        do {
            _ = try flowController.pathComponents(for: pages[1], variant: pages[0])
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.variantNotSupported(identifier: "2"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testPathComponents_variants_incorrectVariant() {
        prepareFlowController()
        let page  = newPage("4", supportVariants: true)
        let pages = newPage("1") =>>
            [
                newPage("2") => page,
                newPage("3") => page
        ]
        try! flowController.register(path: pages)
        do {
            _ = try flowController.pathComponents(for: page, variant: pages[0][0])
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.unregisteredPathIdentifier(identifier: "1_4"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testPathComponents_variants() {
        prepareFlowController()
        let page  = newPage("4", supportVariants: true)
        let pages = newPage("1") =>>
            [
                newPage("2") => page,
                newPage("3") => page
        ]
        try! flowController.register(path: pages)
        do {
            let paths1 = try flowController.pathComponents(for: page, variant: pages[0][1])
            let paths2 = try flowController.pathComponents(for: page, variant: pages[1][1])
            XCTAssertEqual(paths1, "1/2/2_4")
            XCTAssertEqual(paths2, "1/3/3_4")
        } catch _ {
            XCTFail()
        }
    }
    
    // MARK: - currentPathComponents
    
    func testCurrentPathComponents_thereIsNoVisibleStep() {
        prepareFlowController()
        let pages = newPage("1")
        do {
            try flowController.register(path: pages)
            XCTAssertNil(flowController.currentPathComponents())
        } catch _ {
            XCTFail()
        }
    }
    
    func testCurrentPathComponents_visibleStepDoesntSupportVariant() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[1])
            XCTAssertEqual(flowController.currentPathComponents(), "1/2")
        } catch _ {
            XCTFail()
        }
    }
    
    func testCurrentPathComponents_visibleStepSupportsVariant() {
        prepareFlowController()
        let page  = newPage("4", supportVariants: true)
        let pages = newPage("1") =>>
            [
                newPage("2") => page,
                newPage("3") => page
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(page: page, variant: pages[0][1])
            XCTAssertEqual(flowController.currentPathComponents(), "1/2/2_4")
        } catch _ {
            XCTFail()
        }
    }
 
}
