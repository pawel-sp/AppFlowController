//
//  AppFlowController+OperatorsTests.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 20.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_OperatorsTests: XCTestCase {
    
//    // MARK: - Helpers
//    
//    func newPage() -> AppFlowControllerPage {
//        return AppFlowControllerPage(
//            name: "",
//            viewControllerBlock: { UIViewController() },
//            viewControllerType: UIViewController.self
//        )
//    }
//    
//    func newTransition() -> AppFlowControllerTransition {
//        return PushPopAppFlowControllerTransition()
//    }
//    
//    // MARK: - Tests
//    
//    // => ARROW
//    // =>> DOUBLE ARROW
//    
//    // MARK: - => (AppFlowControllerItem, AppFlowControllerTransition) -> (AppFlowControllerItem, AppFlowControllerTransition)
//    
////    ZMIEN EQUAL ZEBY SPRAWDZAL TYLKO NAME -> hasEqualName(to ...)
////    zrob osobne equal ktore sprawdza wszystko
//    
//    func testArrow1() {
//        let item       = newPage()
//        let transition = newTransition()
//        let result     = item => transition
//        XCTAssertTrue(item.isEqual(item: result.item))
//        XCTAssertTrue(transition.isEqual(result.transition))
//    }
//    
//    // MARK: - => (AppFlowControllerTransition, AppFlowControllerItem) -> AppFlowControllerItem
//    
//    func testArrow2() {
//        let item       = newPage()
//        let transition = newTransition()
//        let result     = transition => item
//        XCTAssertTrue(result.isEqual(item: item))
//        XCTAssertTrue(result.forwardTransition?.isEqual(transition) ?? false)
//        XCTAssertTrue(result.backwardTransition?.isEqual(transition) ?? false)
//    }
//    
//    // MARK: - => (AppFlowControllerItem, AppFlowControllerItem) -> [AppFlowControllerItem]
//    
//    func testArrow3_currentTransitionsAreNil() {
//        let item1 = newPage()
//        var item2 = newPage()
//        item2.forwardTransition  = nil
//        item2.backwardTransition = nil
//        let result = item1 => item2
//        XCTAssertTrue(result[1].forwardTransition?.isEqual(PushPopAppFlowControllerTransition.default) ?? false)
//        XCTAssertTrue(result[1].backwardTransition?.isEqual(PushPopAppFlowControllerTransition.default) ?? false)
//    }
//    
//    func testArrow3_currentTransitionsAreNotNil() {
//        let item1 = newPage()
//        var item2 = newPage()
//        let item2ForwardTransition  = newTransition()
//        let item2BackwardTransition = newTransition()
//        item2.forwardTransition  = item2ForwardTransition
//        item2.backwardTransition = item2BackwardTransition
//        let result = item1 => item2
//        XCTAssertTrue(result[1].forwardTransition?.isEqual(item2ForwardTransition) ?? false)
//        XCTAssertTrue(result[1].backwardTransition?.isEqual(item2BackwardTransition) ?? false)
//    }
//    
    
}
