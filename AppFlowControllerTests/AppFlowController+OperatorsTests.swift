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
    
    // MARK: - Helpers
    
    func newPage() -> AppFlowControllerPage {
        return AppFlowControllerPage(
            name: "",
            viewControllerBlock: { UIViewController() },
            viewControllerType: UIViewController.self
        )
    }
    
    func newTransition() -> AppFlowControllerTransition {
        return PushPopAppFlowControllerTransition()
    }
    
    // MARK: - Tests
    
    // => ARROW
    // =>> DOUBLE ARROW

    // MARK: - => (AppFlowControllerItem, AppFlowControllerTransition) -> (AppFlowControllerItem, AppFlowControllerTransition)

    func testArrow1() {
        let item       = newPage()
        let transition = newTransition()
        let result     = item => transition
        XCTAssertEqual(item, result.page)
        XCTAssertTrue(transition.isEqual(result.transition))
    }

    // MARK: - => (AppFlowControllerTransition, AppFlowControllerItem) -> AppFlowControllerItem
    
    func testArrow2() {
        let item       = newPage()
        let transition = newTransition()
        let result     = transition => item
        XCTAssertTrue(result.forwardTransition?.isEqual(transition) ?? false)
        XCTAssertTrue(result.backwardTransition?.isEqual(transition) ?? false)
    }

    // MARK: - => (AppFlowControllerItem, AppFlowControllerItem) -> [AppFlowControllerItem]

    func testArrow3_currentTransitionsAreNil() {
        let item1 = newPage()
        var item2 = newPage()
        item2.forwardTransition  = nil
        item2.backwardTransition = nil
        let result = item1 => item2
        XCTAssertTrue(result[1].forwardTransition?.isEqual(PushPopAppFlowControllerTransition.default) ?? false)
        XCTAssertTrue(result[1].backwardTransition?.isEqual(PushPopAppFlowControllerTransition.default) ?? false)
    }

    func testArrow3_currentTransitionsAreNotNil() {
        let item1 = newPage()
        var item2 = newPage()
        let item2ForwardTransition  = newTransition()
        let item2BackwardTransition = newTransition()
        item2.forwardTransition  = item2ForwardTransition
        item2.backwardTransition = item2BackwardTransition
        let result = item1 => item2
        XCTAssertTrue(result[1].forwardTransition?.isEqual(item2ForwardTransition) ?? false)
        XCTAssertTrue(result[1].backwardTransition?.isEqual(item2BackwardTransition) ?? false)
    }
    
    // MARK: - => ((AppFlowControllerPage, AppFlowControllerTransition), AppFlowControllerPage) -> [AppFlowControllerPage]
    
    func testArrow4() {
        let transition        = newTransition()
        let itemAndTransition = (newPage(), transition)
        let item              = newPage()
        let result            = itemAndTransition => item
        XCTAssertNil(result[0].forwardTransition)
        XCTAssertNil(result[0].backwardTransition)
        XCTAssertTrue(result[1].forwardTransition?.isEqual(transition) ?? false)
        XCTAssertTrue(result[1].backwardTransition?.isEqual(transition) ?? false)
    }
    
    // MARK: - => ([AppFlowControllerPage], AppFlowControllerTransition) -> ([AppFlowControllerPage], AppFlowControllerTransition)
    
    func testArrow5() {
        let pages      = [newPage()]
        let transition = newTransition()
        let result     = pages => transition
        XCTAssertEqual(result.pages, pages)
        XCTAssertTrue(result.transition.isEqual(transition))
    }
    
    // MARK: - => (AppFlowControllerTransition, [AppFlowControllerPage]) -> [AppFlowControllerPage]
    
    func testArrow6_emptyPages() {
        let transition = newTransition()
        let pages:[AppFlowControllerPage] = []
        let result = transition => pages
        XCTAssertEqual(result, pages)
    }
    
    func testArrow6_notEmptyPages() {
        let transition = newTransition()
        let pages      = [
            newPage(),
            newPage()
        ]
        let result     = transition => pages
        var expectedPage1 = newPage()
        expectedPage1.forwardTransition  = transition
        expectedPage1.backwardTransition = transition
        let expectedPage2 = newPage()
        XCTAssertEqual(result, [
            expectedPage1,
            expectedPage2
        ])
    }
    
    // MARK: - => ([AppFlowControllerPage], AppFlowControllerPage) -> [AppFlowControllerPage]
    
    func testArrow7_transitionIsNil() {
        let pages  = [newPage()]
        var page   = newPage()
        let result = pages => page
        page.forwardTransition  = PushPopAppFlowControllerTransition.default
        page.backwardTransition = PushPopAppFlowControllerTransition.default
        let expectedPages = pages + [page]
        XCTAssertEqual(result, expectedPages)
    }
    
    func testArrow7_transitionIsNotNil() {
        let pages  = [newPage()]
        var page   = newPage()
        page.forwardTransition  = newTransition()
        page.backwardTransition = newTransition()
        let result = pages => page
        XCTAssertEqual(result, pages + [page])
    }
    
    // MARK: - => ([AppFlowControllerPage], [AppFlowControllerPage]) -> [AppFlowControllerPage]
    
    func testArrow8_rightPagesArrayIsEmpty() {
        let leftPages = [newPage()]
        let rightPages:[AppFlowControllerPage] = []
        let result = leftPages => rightPages
        XCTAssertEqual(result, leftPages + rightPages)
    }
    
    func testArrow8_rightPagesArrayIsNotEmpty_transitionIsNil() {
        let leftPage   = newPage()
        var rightPage  = newPage()
        let leftPages  = [leftPage]
        let rightPages = [rightPage]
        let result     = leftPages => rightPages
        rightPage.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage.backwardTransition = PushPopAppFlowControllerTransition.default
        XCTAssertEqual(result, leftPages + [rightPage])
    }
    
    func testArrow8_rightPagesArrayIsNotEmpty_transitionIsNotNil() {
        let leftPage   = newPage()
        var rightPage  = newPage()
        rightPage.forwardTransition  = newTransition()
        rightPage.backwardTransition = newTransition()
        let leftPages  = [leftPage]
        let rightPages = [rightPage]
        let result     = leftPages => rightPages
        XCTAssertEqual(result, leftPages + rightPages)
    }
    
    // MARK: - => (AppFlowControllerPage, [AppFlowControllerPage]) -> [AppFlowControllerPage]
    
    func testArrow9_rightPagesIsEmpty() {
        let leftPage   = newPage()
        let rightPages:[AppFlowControllerPage] = []
        let result     = leftPage => rightPages
        XCTAssertEqual(result, [leftPage] + rightPages)
    }
    
    func testArrow9_rightPagesArrayIsNotEmpty_transitionIsNil() {
        let leftPage   = newPage()
        var rightPage  = newPage()
        let rightPages = [rightPage]
        let result     = leftPage => rightPages
        rightPage.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage.backwardTransition = PushPopAppFlowControllerTransition.default
        let expectedPages = [leftPage] + [rightPage]
        XCTAssertEqual(result, expectedPages)
    }
    
    func testArrow9_rightPagesArrayIsNotEmpty_transitionIsNotNil() {
        let leftPage = newPage()
        var rightPage = newPage()
        rightPage.forwardTransition  = newTransition()
        rightPage.backwardTransition = newTransition()
        let rightPages = [rightPage]
        let result = leftPage => rightPages
        XCTAssertEqual(result, [leftPage] + rightPages)
    }
    
    // MARK: - => ((items:[AppFlowControllerPage], AppFlowControllerTransition), AppFlowControllerPage) -> [AppFlowControllerPage]
    
    func testArrow10() {
        let leftPages      = [newPage()]
        let leftTransition = newTransition()
        var rightPage      = newPage()
        let result         = (leftPages, leftTransition) => rightPage
        rightPage.forwardTransition  = leftTransition
        rightPage.backwardTransition = leftTransition
        XCTAssertEqual(result, leftPages + [rightPage])
    }
    
    // MARK: - =>> (AppFlowControllerPage, [Any]) -> [[AppFlowControllerPage]]

    func testDoubleArrow1_rhsIsArrayOfPages() {
        let leftPage   = newPage()
        var rightPage1 = newPage()
        rightPage1.forwardTransition  = newTransition()
        rightPage1.backwardTransition = newTransition()
        var rightPage2 = newPage()
        let rightPages = [rightPage1, rightPage2]
        
        let result     = leftPage =>> rightPages
        
        rightPage2.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage2.backwardTransition = PushPopAppFlowControllerTransition.default
        let expectedResult = [
            [
                leftPage,
                rightPage1
            ],
            [
                leftPage,
                rightPage2
            ]
        ]
        XCTAssertEqual(result[0], expectedResult[0])
        XCTAssertEqual(result[1], expectedResult[1])
        XCTAssertEqual(result.count, 2)
    }
    
    func testDoubleArrow1_rhsIsArrayOfPagesArray() {
        let leftPage = newPage()
        var rightPage1 = newPage()
        var rightPage2 = newPage()
        var rightPage3 = newPage()
        
        rightPage2.forwardTransition  = newTransition()
        rightPage2.backwardTransition = newTransition()
        
        let rightPages = [
            [
                rightPage1,
                rightPage2
            ],
            [
                rightPage3
            ]
        ]
        
        let result = leftPage =>> rightPages
        rightPage1.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage1.backwardTransition = PushPopAppFlowControllerTransition.default
        rightPage3.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage3.backwardTransition = PushPopAppFlowControllerTransition.default
        let expectedResult = [
            [
                leftPage,
                rightPage1,
                rightPage2
            ],
            [
                leftPage,
                rightPage3
            ]
        ]
        XCTAssertEqual(result[0], expectedResult[0])
        XCTAssertEqual(result[1], expectedResult[1])
        XCTAssertEqual(result.count, 2)
    }
    
    func testDoubleArrow1_rhsIsAThreeLevelArray() {
        let leftPage = newPage()
        var rightPage1 = newPage()
        var rightPage2 = newPage()
        var rightPage3 = newPage()
        
        rightPage2.forwardTransition  = newTransition()
        rightPage2.backwardTransition = newTransition()
        
        let rightPages = [
            [
                [
                    rightPage1
                ],
                [
                    rightPage2
                ]
            ],
            [
                rightPage3
            ]
        ]
        
        let result = leftPage =>> rightPages
        rightPage1.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage1.backwardTransition = PushPopAppFlowControllerTransition.default
        rightPage3.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage3.backwardTransition = PushPopAppFlowControllerTransition.default
        
        let expectedResult = [
            [
                leftPage,
                rightPage1
            ],
            [
                leftPage,
                rightPage2
            ],
            [
                leftPage,
                rightPage3
            ]
        ]
        
        XCTAssertEqual(result[0], expectedResult[0])
        XCTAssertEqual(result[1], expectedResult[1])
        XCTAssertEqual(result[2], expectedResult[2])
        XCTAssertEqual(result.count, 3)
    }
    
    // MARK: - =>> ([AppFlowControllerPage], [Any]) -> [[AppFlowControllerPage]]
    
    func testDoubleArrow2_rhsIsArrayOfPages() {
        let leftPage   = newPage()
        var rightPage1 = newPage()
        rightPage1.forwardTransition  = newTransition()
        rightPage1.backwardTransition = newTransition()
        var rightPage2 = newPage()
        let rightPages = [rightPage1, rightPage2]
        
        let result     = [leftPage] =>> rightPages
        
        rightPage2.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage2.backwardTransition = PushPopAppFlowControllerTransition.default
        let expectedResult = [
            [
                leftPage,
                rightPage1
            ],
            [
                leftPage,
                rightPage2
            ]
        ]
        XCTAssertEqual(result[0], expectedResult[0])
        XCTAssertEqual(result[1], expectedResult[1])
        XCTAssertEqual(result.count, 2)
    }
    
    func testDoubleArrow2_rhsIsArrayOfPagesArray() {
        let leftPage   = newPage()
        var rightPage1 = newPage()
        var rightPage2 = newPage()
        var rightPage3 = newPage()
        
        rightPage2.forwardTransition  = newTransition()
        rightPage2.backwardTransition = newTransition()
        
        let rightPages = [
            [
                rightPage1,
                rightPage2
            ],
            [
                rightPage3
            ]
        ]
        
        let result = [leftPage] =>> rightPages
        rightPage1.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage1.backwardTransition = PushPopAppFlowControllerTransition.default
        rightPage3.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage3.backwardTransition = PushPopAppFlowControllerTransition.default
        let expectedResult = [
            [
                leftPage,
                rightPage1,
                rightPage2
            ],
            [
                leftPage,
                rightPage3
            ]
        ]
        XCTAssertEqual(result[0], expectedResult[0])
        XCTAssertEqual(result[1], expectedResult[1])
        XCTAssertEqual(result.count, 2)
    }
    
    func testDoubleArrow2_rhsIsAThreeLevelArray() {
        let leftPage   = newPage()
        var rightPage1 = newPage()
        var rightPage2 = newPage()
        var rightPage3 = newPage()
        
        rightPage2.forwardTransition  = newTransition()
        rightPage2.backwardTransition = newTransition()
        
        let rightPages = [
            [
                [
                    rightPage1
                ],
                [
                    rightPage2
                ]
            ],
            [
                rightPage3
            ]
        ]
        
        let result = [leftPage] =>> rightPages
        rightPage1.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage1.backwardTransition = PushPopAppFlowControllerTransition.default
        rightPage3.forwardTransition  = PushPopAppFlowControllerTransition.default
        rightPage3.backwardTransition = PushPopAppFlowControllerTransition.default
        
        let expectedResult = [
            [
                leftPage,
                rightPage1
            ],
            [
                leftPage,
                rightPage2
            ],
            [
                leftPage,
                rightPage3
            ]
        ]
        
        XCTAssertEqual(result[0], expectedResult[0])
        XCTAssertEqual(result[1], expectedResult[1])
        XCTAssertEqual(result[2], expectedResult[2])
        XCTAssertEqual(result.count, 3)
    }

    
}
