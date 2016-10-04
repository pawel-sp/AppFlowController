//
//  AppFlowControllerPathStep.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 04.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import Foundation

class PathStep {
    
    // MARK: - Properties
    
    let current:AppFlowControllerItem
    private var children:[PathStep] = []
    weak var parent:PathStep?
    
    // MARK: - Init
    
    init(item:AppFlowControllerItem) {
        self.current = item
    }
    
    // MARK: - Utilities
    
    func add(item:AppFlowControllerItem) -> PathStep {
        let step = PathStep(item: item)
        children.append(step)
        step.parent = self
        return step
    }
    
    func getChildren() -> [PathStep] {
        return children
    }
    
    func search(item:AppFlowControllerItem) -> PathStep? {
        return search(compareBlock: { $0.current.isEqual(item: item) })
    }
    
    func search(forName name:String) -> PathStep? {
        return search(compareBlock: { $0.current.name == name })
    }
    
    func allParentItems(fromStep step:PathStep) -> [AppFlowControllerItem] {
        var items:[AppFlowControllerItem] = [step.current]
        var current = step
        while let parent = current.parent {
            current = parent
            items.insert(parent.current, at: 0)
        }
        return items
    }
    
    func distanceToStepWithItem(item:AppFlowControllerItem) -> Int? {
        var counter = 0
        var found   = false
        var current = self
        while let parent = current.parent {
            current = parent
            counter += 1
            if parent.current.isEqual(item: item) {
                found = true
                break
            }
        }
        return found ? counter : nil
    }
    
    func distanceBetween(step step1:PathStep, andStep step2:PathStep) -> (up:Int, down:Int) {
        let step1Parents = step1.allParentItems(fromStep: step1)
        let step2Parents = step2.allParentItems(fromStep: step2)
        var commonItems:[AppFlowControllerItem] = []
        for step1Parent in step1Parents {
            for step2Parent in step2Parents {
                if step1Parent.isEqual(item: step2Parent) {
                    commonItems.append(step1Parent)
                }
            }
        }
        if let firtCommonItem = commonItems.last {
            let step1Distance = step1.distanceToStepWithItem(item: firtCommonItem)
            let step2Distance = step2.distanceToStepWithItem(item: firtCommonItem)
            return (step1Distance ?? 0, step2Distance ?? 0)
        } else {
            return (0,0)
        }
    }
    
    // MARK: - Private
    
    private func search(compareBlock:(PathStep) -> Bool) -> PathStep? {
        if compareBlock(self) {
            return self
        } else {
            for child in children {
                if let found = child.search(compareBlock: compareBlock) {
                    return found
                }
            }
            return nil
        }
    }
}
