//
//  AppFlowController+CoreTests+Pop.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 24.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {

    func testPop_missingPrepareMethodInvokation() {
        do {
            try flowController.pop(to: newPage("1"))
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.missingConfiguration)
            } else {
                XCTFail()
            }
        }
    }
    
    func testPop_unregisterepPath() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(path: pages)
            try flowController.pop(to: newPage("3"))
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.unregisteredPathIdentifier(identifier: "3"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testPop_poppingToSkippedPage() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[3],
                animated: false,
                skipPages:[
                    pages[2]
                ]
            )
            try flowController.pop(to: pages[2])
            XCTFail()
            
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.popToSkippedPath(identifier: "3"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testPop_poppingToStepWithCustomBackwardTransition() {
        prepareFlowController(fakeNC: true)
        let transition = TestTransition()
        let pages      = newPage("1") => transition => newPage("2") => transition => newPage("3")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[2], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2", "3"])
            
            try flowController.pop(to: pages[1])
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testPop() {
        prepareFlowController(fakeNC: true)
        let pages      = newPage("1") => newPage("2") => newPage("3")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[2], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2", "3"])
            
            try flowController.pop(to: pages[1])
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
        } catch _ {
            XCTFail()
        }
    }
    
}
