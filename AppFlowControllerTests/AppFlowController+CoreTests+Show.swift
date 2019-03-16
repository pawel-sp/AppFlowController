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
            try flowController.show(page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.missingConfiguration)
            } else {
                XCTFail()
            }
        }
    }
    
    func testShow_missingVariantWhenSupportVariantsIsTrue() {
        prepareFlowController()
        let page = newPage("page", supportVariants: true)
        do {
            try flowController.show(page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.missingVariant(identifier: "page"))
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
            try flowController.show(page, variant: variant)
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.variantNotSupported(identifier: "page"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testShow_pageDoesntExist() {
        prepareFlowController()
        let page = newPage("page")
        do {
            try flowController.show(page)
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.unregisteredPathIdentifier(identifier: "page"))
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
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[1], animated: false)
            XCTAssertEqual(currentVCNames, ["1", "2"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_noCurrentStep_skippingPages_onlyPushes() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[2], animated: false, skipPathComponents:[pages[1]])
            XCTAssertEqual(currentVCNames, ["1", "3"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_noCurrentStep_skippingPages_includingCustomTransition() {
        prepareFlowController()
        let transition = TestTransition()
        let pages = newPage("1") => newPage("2") => transition => newPage("3")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[2], animated: false, skipPathComponents: [pages[1]])
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
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[2],
                parameters: [
                    TransitionParameter(pathComponent: pages[1], value: "2_parameter"),
                    TransitionParameter(pathComponent: pages[2], value: "3_parameter"),
                    TransitionParameter(pathComponent: pages[3], value: "4_parameter"),
                    TransitionParameter(pathComponent: incorrectPage, value: "parameter")
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
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[2],
                parameters: [
                    TransitionParameter(pathComponent: pages[1], value: "2_parameter"),
                    TransitionParameter(pathComponent: pages[2], value: "3_parameter"),
                    TransitionParameter(pathComponent: pages[3], value: "4_parameter"),
                    TransitionParameter(pathComponent: incorrectPage, value: "parameter")
                ],
                animated: false,
                skipPathComponents: [
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
            try flowController.register(pathComponents: pages)
            try flowController.show(
                variantedPage,
                variant: pages[0][1],
                parameters: [
                    TransitionParameter(pathComponent: variantedPage, variant:pages[0][1], value: "parameter1")
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
    
    func testShow_noCurrentStep_parameters_variants_incorrectVariant() {
        prepareFlowController()
        let variantedPage = newPage("4", supportVariants: true)
        let pages = newPage("1") =>> [
            newPage("2") => variantedPage,
            newPage("3") => variantedPage
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                variantedPage,
                variant: pages[0][0],
                animated: false
            )
            XCTFail()
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.unregisteredPathIdentifier(identifier: "1_4"))
            } else {
                XCTFail()
            }
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
            try flowController.register(pathComponents: pages)
            try flowController.show(
                variantedPage,
                variant: pages[0][2],
                parameters: [
                    TransitionParameter(pathComponent: variantedPage, variant:pages[0][2], value: "parameter1"),
                    TransitionParameter(pathComponent: variantedPage, variant:pages[1][1], value: "parameter2")
                ],
                animated: false,
                skipPathComponents: [
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
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[1], animated: false)
            try flowController.show(pages[3], animated: false)
            XCTAssertEqual(currentVCNames, ["1", "2", "3", "4"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_movingBackward() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[2], animated: false)
            try flowController.show(pages[0], animated: false)
            XCTAssertEqual(currentVCNames, ["1"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_movingBackwardAndForward() {
        prepareFlowController()
        let pages = newPage("1") =>> [
            newPage("2") => newPage("3"),
            newPage("4") => newPage("5")
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[0][2], animated: false)
            try flowController.show(pages[1][2], animated: false)
            XCTAssertEqual(currentVCNames, ["1", "4", "5"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_skippingPage() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[1], animated: false)
            try flowController.show(
                pages[3],
                animated: false,
                skipPathComponents: [
                    pages[2]
                ]
            )
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_skippingPage_showPagePreviouslySkipped() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[1], animated: false)
            try flowController.show(
                pages[3],
                animated: false,
                skipPathComponents: [
                    pages[2]
                ]
            )
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
            try flowController.show(pages[1], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
            try flowController.show(pages[2], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2", "3"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_skippingPage_clearingSkippedPageBeforeNextShow() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[1], animated: false)
            try flowController.show(
                pages[3],
                animated: false,
                skipPathComponents: [pages[2]]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
            try flowController.show(pages[1], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
            try flowController.show(pages[3], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2", "3", "4"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_parameters() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[3],
                parameters: [
                    TransitionParameter(pathComponent: pages[3], value: "par4"),
                    TransitionParameter(pathComponent: pages[2], value: "par3")
                ],
                animated: false
            )
            
            XCTAssertEqual(flowController.tracker.parameter(for: "4"), "par4")
            XCTAssertEqual(flowController.tracker.parameter(for: "3"), "par3")

            try flowController.show(pages[2])

            XCTAssertNil(flowController.tracker.parameter(for: "4"))
            XCTAssertEqual(flowController.tracker.parameter(for: "3"), "par3")
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_showTheSamePageAsCurrentOne() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(pages[1], animated: false)
            try flowController.show(pages[1], animated: false)
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_showPageWhichIsSkippedAtTheSameTime() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[1],
                animated: false,
                skipPathComponents:[pages[1]]
            )
            XCTAssertEqual(currentVCNames, ["1"])
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_showPreviousPageWhereThereAreToSkippedPages_test1() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[3],
                animated: false,
                skipPathComponents:[
                    pages[2]
                ]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
            try flowController.show(
                pages[0],
                animated: false
            )
            
            XCTAssertEqual(currentVCNames, ["1"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_showPreviousPageWhereThereAreToSkippedPages_test2() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[3],
                animated: false,
                skipPathComponents:[
                    pages[2]
                ]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
            try flowController.show(
                pages[1],
                animated: false
            )
            
            XCTAssertEqual(currentVCNames, ["1", "2"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_showPreviousPageWhereThereAreToSkippedPages_test3() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[3],
                animated: false,
                skipPathComponents:[
                    pages[1],
                    pages[2]
                ]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "4"])
            
            try flowController.show(
                pages[0],
                animated: false
            )
            
            XCTAssertEqual(currentVCNames, ["1"])
            
        } catch _ {
            XCTFail()
        }
    }
    
    func testShow_currentStepExists_showPreviouslySkippedPage() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") => newPage("3") => newPage("4")
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[3],
                animated: false,
                skipPathComponents:[
                    pages[2]
                ]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "2", "4"])
            
            try flowController.show(
                pages[2],
                animated: false
            )
            
            XCTFail()
            
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.showingSkippedPath(identifier: "3"))
            } else {
                XCTFail()
            }
        }
    }
    
    func testShow_currentStepExists_tryingToShowPageFromSkippedPage() {
        prepareFlowController()
        let pages = newPage("1") => newPage("2") =>>
        [
                newPage("3") => newPage("4"),
                newPage("5")
        ]
        do {
            try flowController.register(pathComponents: pages)
            try flowController.show(
                pages[1][2],
                animated: false,
                skipPathComponents:[
                    pages[1][1]
                ]
            )
            
            XCTAssertEqual(currentVCNames, ["1", "5"])
            
            try flowController.show(
                pages[0][3],
                animated: false
            )
            
            XCTFail()
            
        } catch let error {
            if let afcError = error as? AFCError {
                XCTAssertEqual(afcError, AFCError.showingSkippedPath(identifier: "2"))
            } else {
                XCTFail()
            }
        }

    }
   
}
