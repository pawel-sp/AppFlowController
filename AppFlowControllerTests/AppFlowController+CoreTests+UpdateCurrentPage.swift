//
//  AppFlowController+CoreTests+UpdateCurrentPage.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 26.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {
    
    func testRegister_nameDoesntExist() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.updateCurrentPath(with: UIViewController(), for: "3")
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.unregisteredPathIdentifier(identifier: "3"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testRegister_nameExists() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        let viewController = UIViewController()
        do {
            try flowController.register(pathComponents: pages)
            
            XCTAssertNil(flowController.tracker.viewController(for: "2"))
            
            try flowController.updateCurrentPath(with: viewController, for: "2")
            
            XCTAssertEqual(flowController.tracker.viewController(for: "2"), viewController)
            
        } catch _ {
            XCTFail()
        }
    }
    
}
