//
//  AppFlowController+PathStepTests.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import AppFlowController

class AppFlowController_PathStepTests: XCTestCase {
    
    // MARK: - Helpers
    
    func newPage(name:String = "page", variant:String? = nil) -> FlowPathComponent {
        var result = FlowPathComponent(name: name, viewControllerInit: { UIViewController() }, viewControllerType: UIViewController.self)
        result.variantName = variant
        return result
    }
    
    func newRootStep() -> PathStep {
        return PathStep(pathComponent: newPage(name: "root"))
    }
    
    // MARK: - Properties
    
    var root: PathStep!
    
    // MARK: - Setup
    
    override func setUp() {
        root = newRootStep()
    }
    
    // MARK: - Tests
    
    func testInit_assingsCorrectlyPage() {
        let page = newPage()
        let step = PathStep(pathComponent: page)
        XCTAssertEqual(step.pathComponent, page)
    }
    
    func testAdd_childrenIsEmpty() {
        let page = newPage()
        root.add(pathComponent: page)
        XCTAssertEqual(root.children.count, 1)
        XCTAssertEqual(root.children[0].pathComponent, page)
        XCTAssertEqual(root.children[0].parent, root)
        XCTAssertEqual(root.children[0].children, [])
    }
    
    func testSearchPage_idenditierDoesntExist() {
        XCTAssertNil(root.search(pathComponent: newPage()))
    }
    
    func testSearchPage_identifierExists() {
        let page = newPage()
        root.add(pathComponent: page)
        XCTAssertEqual(root.search(pathComponent: page)?.pathComponent, page)
        XCTAssertEqual(root.search(pathComponent: page)?.parent, root)
        XCTAssertEqual(root.search(pathComponent: page)!.children, [])
    }
    
    func testSearchPage_idExistsButWithVariant() {
        let page = newPage(name: "page", variant: "variant")
        let page_withoutVariant = newPage(name: "page", variant: nil)
        
        root.add(pathComponent: page)
        
        XCTAssertEqual(root.search(pathComponent: page)?.pathComponent, page)
        XCTAssertEqual(root.search(pathComponent: page)?.parent, root)
        XCTAssertEqual(root.search(pathComponent: page)!.children, [])
        
        XCTAssertNil(root.search(pathComponent: page_withoutVariant))
    }
    
    func testSearchID_idDoesntExist() {
        XCTAssertNil(root.search(identifier: "page"))
    }
    
    func testSearchID_idAlreadyExists() {
        let page = newPage(name: "page_to_find")
        root.add(pathComponent: page)
        XCTAssertEqual(root.search(identifier: "page_to_find")?.pathComponent, page)
        XCTAssertEqual(root.search(identifier: "page_to_find")?.parent, root)
        XCTAssertEqual(root.search(identifier: "page_to_find")!.children, [])
    }
    
    func testSearchID_idExistsButWithVariant() {
        let page = newPage(name: "page_to_find", variant: "variant")
        
        root.add(pathComponent: page)
        
        XCTAssertEqual(root.search(identifier: "variant_page_to_find")?.pathComponent, page)
        XCTAssertEqual(root.search(identifier: "variant_page_to_find")?.parent, root)
        XCTAssertEqual(root.search(identifier: "variant_page_to_find")!.children, [])
        
        XCTAssertNil(root.search(identifier: "page_to_find"))
    }
    
    func testAllParentPages_stepHasNoParents_includeSelfIsFalse() {
        let step = PathStep(pathComponent: newPage())
        XCTAssertEqual(root.allParentPathComponents(from: step, includeSelf: false), [])
    }
    
    func testAllParentPages_stepHasNoParents_includeSelfIsTrue() {
        let step = PathStep(pathComponent: newPage())
        XCTAssertEqual(root.allParentPathComponents(from: step, includeSelf: true), [step.pathComponent])
    }
    
    func testAllParentPages_stepHasOnlyOneParent_includeSelfIsFalse() {
        let page = newPage()
        root.add(pathComponent: page)
        XCTAssertEqual(root.allParentPathComponents(from: root.children.first!, includeSelf: false), [root.pathComponent])
    }
    
    func testAllParentPages_stepHasOnlyOneParent_includeSelfIsTrue() {
        let page = newPage()
        root.add(pathComponent: page)
        XCTAssertEqual(root.allParentPathComponents(from: root.children.first!, includeSelf: true), [root.pathComponent, page])
    }
    
    func testAllParentPages_stepHasFewParents_includeSelfIsFalse() {
        let page1 = newPage()
        let page2 = newPage()
        root.add(pathComponent: page1)
        root.children.first!.add(pathComponent: page2)
        XCTAssertEqual(root.allParentPathComponents(from: root.children.first!.children.first!, includeSelf: false), [root.pathComponent, page1])
    }
    
    func testAllParentPages_stepHasFewParents_includeSelfIsTrue() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        root.add(pathComponent: page1)
        root.children.first!.add(pathComponent: page2)
        XCTAssertEqual(root.allParentPathComponents(from: root.children.first!.children.first!, includeSelf: true), [root.pathComponent, page1, page2])
    }
    
    func testFirstParentPage_noMatches() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        root.add(pathComponent: page1).add(pathComponent: page2)
        XCTAssertNil(root.firstParentPathComponent(where: { $0.name == "3" }))
    }
    
    func testFirstParentPage_onlyOneMatch() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        let step1 = root.add(pathComponent: page1)
        let step2 = step1.add(pathComponent: page2)
        
        XCTAssertEqual(step2.firstParentPathComponent(where: { $0.name == "1" }), page1)
    }
    
    func testFirstParentPage_fewMatches() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        let page3 = newPage(name: "3")

        let step1 = root.add(pathComponent: page1)
        let step2 = step1.add(pathComponent: page2)
        let step3 = step2.add(pathComponent: page3)
        
        XCTAssertEqual(step3.firstParentPathComponent(where: { _ in true }), page2)
    }
    
    func testDistanceToStep_thereIsNoParentWithThatPage() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        root.add(pathComponent: page1)
        let page = root.children.first!.add(pathComponent: page2)
        XCTAssertNil(page.distanceToStep(with: newPage(name: "3")))
    }
 
    func testDistanceToStep_thereIsParentWithThatPage() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        root.add(pathComponent: page1)
        let page = root.children.first!.add(pathComponent: page2)
        XCTAssertEqual(page.distanceToStep(with: page2), 0)
        XCTAssertEqual(page.distanceToStep(with: page1), 1)
        XCTAssertEqual(page.distanceToStep(with: root.pathComponent), 2)
    }
    
    func testDistanceToStep_thereIsChildrenWithThatPage() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        root.add(pathComponent: page1)
        root.children.first!.add(pathComponent: page2)
        XCTAssertEqual(root.children.first!.distanceToStep(with: page1), 0)
        XCTAssertEqual(root.children.first!.distanceToStep(with: root.pathComponent), 1)
        XCTAssertNil(root.children.first!.distanceToStep(with: page2))
    }
    
    func testDistanceBetween_stepsAreTheSame() {
        let page = newPage()
        let step = root.add(pathComponent: page)
        
        XCTAssertEqual(PathStep.distanceBetween(step: step, and: step).up, 0)
        XCTAssertEqual(PathStep.distanceBetween(step: step, and: step).down, 0)
        
        XCTAssertEqual(PathStep.distanceBetween(step: root, and: root).up, 0)
        XCTAssertEqual(PathStep.distanceBetween(step: root, and: root).down, 0)
    }
    
    func testDistanceBetween_step2IsTwoLevelLowerThenStep1() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        let step1 = root.add(pathComponent: page1)
        let step2 = step1.add(pathComponent: page2)
        
        XCTAssertEqual(PathStep.distanceBetween(step: root, and: step1).up, 0)
        XCTAssertEqual(PathStep.distanceBetween(step: root, and: step1).down, 1)
        
        XCTAssertEqual(PathStep.distanceBetween(step: root, and: step2).up, 0)
        XCTAssertEqual(PathStep.distanceBetween(step: root, and: step2).down, 2)
        
        XCTAssertEqual(PathStep.distanceBetween(step: step1, and: step2).up, 0)
        XCTAssertEqual(PathStep.distanceBetween(step: step1, and: step2).down, 1)
        
        XCTAssertEqual(PathStep.distanceBetween(step: step2, and: root).up, 2)
        XCTAssertEqual(PathStep.distanceBetween(step: step2, and: root).down, 0)
        
        XCTAssertEqual(PathStep.distanceBetween(step: step2, and: step1).up, 1)
        XCTAssertEqual(PathStep.distanceBetween(step: step2, and: step1).down, 0)
        
        XCTAssertEqual(PathStep.distanceBetween(step: step1, and: root).up, 1)
        XCTAssertEqual(PathStep.distanceBetween(step: step1, and: root).down, 0)
    }
    
//        R
//       / \
//      1   2
//     / \
//    3   4
    func testDistanceBetween_stepsHaveDifferentParents() {
        let page1 = newPage(name: "1")
        let page2 = newPage(name: "2")
        let page3 = newPage(name: "3")
        let page4 = newPage(name: "4")
        let step1 = root.add(pathComponent: page1)
        let step2 = root.add(pathComponent: page2)
        let step3 = step1.add(pathComponent: page3)
        let step4 = step1.add(pathComponent: page4)
        
        XCTAssertEqual(PathStep.distanceBetween(step: step3, and: step2).up, 2)
        XCTAssertEqual(PathStep.distanceBetween(step: step3, and: step2).down, 1)
        
        XCTAssertEqual(PathStep.distanceBetween(step: step3, and: step4).up, 1)
        XCTAssertEqual(PathStep.distanceBetween(step: step3, and: step4).down, 1)
    }
    
}
