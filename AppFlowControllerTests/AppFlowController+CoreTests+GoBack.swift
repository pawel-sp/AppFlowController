//
//  AppFlowController+CoreTests+GoBack.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 24.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {
    
    func testGoBack_thereIsNoVisibleStep() {
        prepareFlowController()
        flowController.goBack()
        XCTAssertEqual(currentVCNames, [])
    }
    
    func testGoBack_visibleStep_onePageBackward() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[1], animated: false)
            flowController.goBack(animated:false)
            
            XCTAssertEqual(currentVCNames, ["1"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testGoBack_visibleStep_twoPagesBackward_oneIsSkipped() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[3],
                animated: false,
                skipPathComponents: [pages[2]]
            )
            
            flowController.goBack(animated:false)
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testGoBack_visibleStep_goingBackFromRootStep() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[0], animated: false)
            
            flowController.goBack(animated:false)
            
            XCTAssertEqual(currentVCNames, ["1"])
        } catch _ {
            XCTFail()
        }
    }
    
}
