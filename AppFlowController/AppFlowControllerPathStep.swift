//
//  AppFlowControllerPathStep.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 04.10.2016.
//  Copyright (c) 2017 Paweł Sporysz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

class PathStep {
    
    // MARK: - Properties
    
    let current:AppFlowControllerPage
    private(set) var children:[PathStep] = []
    private(set) weak var parent:PathStep?
    
    // MARK: - Init
    
    init(page:AppFlowControllerPage) {
        self.current = page
    }
    
    // MARK: - Utilities
    
    @discardableResult
    func add(page:AppFlowControllerPage) -> PathStep {
        let step = PathStep(page: page)
        children.append(step)
        step.parent = self
        return step
    }
    
    func search(page:AppFlowControllerPage) -> PathStep? {
        return search(compareBlock: { $0.current.identifier == page.identifier })
    }
    
    func search(name:String) -> PathStep? {
        return search(compareBlock: { $0.current.name == name })
    }
    
    func allParentPages(from step:PathStep, includeSelf:Bool = true) -> [AppFlowControllerPage] {
        var pages:[AppFlowControllerPage] = includeSelf ? [step.current] : []
        var current = step
        while let parent = current.parent {
            current = parent
            pages.insert(parent.current, at: 0)
        }
        return pages
    }
    
    func distanceToStep(with page:AppFlowControllerPage) -> Int? {
        
        guard current.identifier != page.identifier else { return 0 }
        
        var counter = 0
        var currentParent = self
        
        while let parent = currentParent.parent {
            currentParent = parent
            counter += 1
            if parent.current.identifier == page.identifier {
                return counter
            }
        }
        return nil
    }
    
    static func distanceBetween(step step1:PathStep, and step2:PathStep) -> (up:Int, down:Int) {
        let step1Parents = step1.allParentPages(from: step1)
        let step2Parents = step2.allParentPages(from: step2)
        var commonPages:[AppFlowControllerPage] = []
        for step1Parent in step1Parents {
            for step2Parent in step2Parents {
                if step1Parent.identifier == step2Parent.identifier {
                    commonPages.append(step1Parent)
                }
            }
        }
        if let firtCommonItem = commonPages.last {
            let step1Distance = step1.distanceToStep(with: firtCommonItem)
            let step2Distance = step2.distanceToStep(with: firtCommonItem)
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

extension PathStep: Equatable {
    
    public static func ==(lhs:PathStep, rhs:PathStep) -> Bool {
        return
            lhs.current == rhs.current &&
            lhs.children == rhs.children &&
            ((lhs.parent == nil && rhs.parent == nil) || lhs.parent?.current == rhs.parent?.current)
    }
    
}



