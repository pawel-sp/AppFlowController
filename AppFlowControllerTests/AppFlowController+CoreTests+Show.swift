//
//  AppFlowController+CoreTests+Show.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

extension AppFlowController_CoreTests {
    
    // MARK: - Show - throw
    
    func testShow_prepareMethodWasntInvoked() {
        let page = newPage()
        do {
            try flowController.show(page: page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.missingConfiguration)
            } else {
                XCTFail()
            }
        }
    }
    
    func testShow_missingVariantWhenSupportVariantsIsTrue() {
        prepareFlowController()
        let page = newPage("page", supportVariants: true)
        do {
            try flowController.show(page: page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.missingVariant(identifier: "page"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testShow_passingVariantWhenSupportVariantsIsFalse() {
        prepareFlowController()
        let page    = newPage("page", supportVariants: false)
        let variant = newPage("variant")
        do {
            try flowController.show(page: page, variant: variant)
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.variantNotSupported(identifier: "page"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testShow_pageDoesntExist() {
        prepareFlowController()
        let page = newPage("page")
        do {
            try flowController.show(page: page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AppFlowControllerError {
                XCTAssertEqual(afcError, AppFlowControllerError.unregisteredPathIdentifier(identifier: "page"))
            } else {
                XCTFail()
            }
        }
    }
    
    // MARK: - Show - no current step
    
    func testShow_noCurrentStep() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[1], animated: false)
            XCTAssertEqual(currentVCNames, ["1", "2"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_noCurrentStep_skippingPages_onlyPushes() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[2], animated: false, skipPages:[pages[1]])
            XCTAssertEqual(currentVCNames, ["1", "3"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_noCurrentStep_skippingPages_includingCustomTransition() {
        prepareFlowController(fakeNC: true)
        let transition = TestTransition()
        let pages = newPage("1") => newPage("2") => transition => newPage("3")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[2], animated: false, skipPages:[pages[1]])
            XCTAssertEqual(currentVCNames, ["1", "3"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_noCurrentStep_parameters() {
        prepareFlowController()
        let incorrectPage = newPage("incorrect")
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[2],
                parameters: [
                    AppFlowControllerParameter(page: pages[1], value: "2_parameter"),
                    AppFlowControllerParameter(page: pages[2], value: "3_parameter"),
                    AppFlowControllerParameter(page: pages[3], value: "4_parameter"),
                    AppFlowControllerParameter(page: incorrectPage, value: "parameter")
                ],
                animated: false
            )
            XCTAssertEqual(currentVCNames, ["1", "2", "3"])
            
            XCTAssertNil(flowController.tracker.parameter(for: "1"))
            XCTAssertNil(flowController.tracker.parameter(for: "4")) // its after page3 so it shouldn't be saved
            
            XCTAssertEqual(flowController.tracker.parameter(for: "2"), "2_parameter")
            XCTAssertEqual(flowController.tracker.parameter(for: "3"), "3_parameter")
            
            XCTAssertNil(flowController.tracker.parameter(for: "incorrect"))
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_noCurrentStep_parameters_skippingPages() {
        prepareFlowController()
        let incorrectPage = newPage("incorrect")
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[2],
                parameters: [
                    AppFlowControllerParameter(page: pages[1], value: "2_parameter"),
                    AppFlowControllerParameter(page: pages[2], value: "3_parameter"),
                    AppFlowControllerParameter(page: pages[3], value: "4_parameter"),
                    AppFlowControllerParameter(page: incorrectPage, value: "parameter")
                ],
                animated: false,
                skipPages: [
                    pages[1]
                ]
            )
            XCTAssertEqual(currentVCNames, ["1", "3"])
            
            XCTAssertNil(flowController.tracker.parameter(for: "1"))
            XCTAssertNil(flowController.tracker.parameter(for: "4")) // its after page3 so it shouldn't be saved
            
            XCTAssertNil(flowController.tracker.parameter(for: "2")) // it's skipped
            XCTAssertEqual(flowController.tracker.parameter(for: "3"), "3_parameter")
            
            XCTAssertNil(flowController.tracker.parameter(for: "incorrect"))
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_noCurrentStep_parameters_variants() {
        prepareFlowController()
        let variantedPage = newPage("4", supportVariants: true)
        let pages = newPage("1") =>> [
            newPage("2") => variantedPage,
            newPage("3") => variantedPage
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: variantedPage,
                variant: pages[0][1],
                parameters: [
                    AppFlowControllerParameter(page: variantedPage, variant:pages[0][1], value: "parameter1"),
                    AppFlowControllerParameter(page: variantedPage, variant:pages[1][1], value: "parameter2")
                ],
                animated: false
            )
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
            XCTAssertNil(flowController.tracker.parameter(for: "4"))
            XCTAssertEqual(flowController.tracker.parameter(for: "2_4"), "parameter1")
            XCTAssertNil(flowController.tracker.parameter(for: "3_4"))
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_noCurrectStep_parameters_variants_skippingPages() {
        prepareFlowController()
        let variantedPage = newPage("5", supportVariants: true)
        let pages = newPage("1") =>> [
            newPage("2") => newPage("3") => variantedPage,
            newPage("4") => variantedPage
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: variantedPage,
                variant: pages[0][2],
                parameters: [
                    AppFlowControllerParameter(page: variantedPage, variant:pages[0][2], value: "parameter1"),
                    AppFlowControllerParameter(page: variantedPage, variant:pages[1][1], value: "parameter2")
                ],
                animated: false,
                skipPages: [
                    pages[0][2]
                ]
            )
            XCTAssertEqual(currentVCNames, ["1", "2", "5"])
            
            XCTAssertNil(flowController.tracker.parameter(for: "5"))
            XCTAssertEqual(flowController.tracker.parameter(for: "3_5"), "parameter1")
            XCTAssertNil(flowController.tracker.parameter(for: "4_5"))
            
        } catch _ {
            XCTFail()
        }
    }
    
    // MARK: - Show - current step exists
    
    func testShow_currentStepExists_movingForward() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[1], animated: false)
            try flowController.show(page: pages[3], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2", "3", "4"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_movingBackward() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[2], animated: false)
            try flowController.show(page: pages[0], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_movingBackwardAndForward() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") =>> [
            newPage("2") => newPage("3"),
            newPage("4") => newPage("5")
        ]
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[0][2], animated: false)
            try flowController.show(page: pages[1][2], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "4", "5"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_skippingPage() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[1], animated: false)
            try flowController.show(
                page: pages[3],
                animated: false,
                skipPages: [
                    pages[2]
                ]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_skippingPage_showPagePreviouslySkipped() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[1], animated: false)
            try flowController.show(
                page: pages[3],
                animated: false,
                skipPages: [
                    pages[2]
                ]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
            try flowController.show(page: pages[1], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
            try flowController.show(page: pages[2], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2", "3"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_skippingPage_clearingSkippedPageBeforeNextShow() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[1], animated: false)
            try flowController.show(
                page: pages[3],
                animated: false,
                skipPages: [
                    pages[2]
                ]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
            try flowController.show(page: pages[1], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
            try flowController.show(page: pages[3], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2", "3", "4"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_parameters() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(
                page: pages[3],
                parameters: [
                    AppFlowControllerParameter(page: pages[3], value: "par4"),
                    AppFlowControllerParameter(page: pages[2], value: "par3")
                ],
                animated: false
            )
            
            XCTAssertEqual(flowController.tracker.parameter(for: "4"), "par4")
            XCTAssertEqual(flowController.tracker.parameter(for: "3"), "par3")

            try flowController.show(page: pages[2])

            XCTAssertNil(flowController.tracker.parameter(for: "4"))
            XCTAssertEqual(flowController.tracker.parameter(for: "3"), "par3")
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_showTheSamePageAsCurrentOne() {
        prepareFlowController(fakeNC: true)
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(path: pages)
            try flowController.show(page: pages[1], animated: false)
            try flowController.show(page: pages[1], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
        } catch _ {
            XCTFail()
        }
    }
   
}
