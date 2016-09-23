//
//  AppFlowController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

protocol AppFlowControllerItem {
    
    var name:String { get }
    var viewController:UIViewController { get }
    var viewControllerType: UIViewController.Type { get }
    
    func isEqual(item:AppFlowControllerItem) -> Bool
    
}

func ==(lhs:AppFlowControllerItem, rhs:AppFlowControllerItem) -> Bool {
    return lhs.isEqual(item: rhs)
}

extension AppFlowControllerItem {
    
    func isEqual(item:AppFlowControllerItem) -> Bool {
        return self.name == item.name
    }
    
}

infix operator =>: AdditionPrecedence

func =>(lhs:AppFlowControllerItem, rhs:AppFlowControllerItem) -> [AppFlowControllerItem] {
    return [lhs, rhs]
}

func =>(lhs:[AppFlowControllerItem], rhs:AppFlowControllerItem) -> [AppFlowControllerItem] {
    return lhs + [rhs]
}

class AppFlowController {

    // MARK: - Classes
    
    private class PathStep {
        
        let current:AppFlowControllerItem
        private var children:[PathStep] = []
        weak var parent:PathStep?
        
        init(item:AppFlowControllerItem) {
            self.current = item
        }
        
        func add(item:AppFlowControllerItem) {
            let step = PathStep(item: item)
            children.append(step)
            step.parent = self
        }
        
        func search(item:AppFlowControllerItem) -> PathStep? {
            if self.current.isEqual(item: item) {
                return self
            } else {
                for child in children {
                    if let found = child.search(item: item) {
                        return found
                    }
                }
                return nil
            }
        }
        
        func itemsFrom(step:PathStep) -> [AppFlowControllerItem] {
            var items:[AppFlowControllerItem] = [step.current]
            var current = step
            while let parent = current.parent {
                current = parent
                items.insert(parent.current, at: 0)
            }
            return items
        }
    }
    
    // MARK: - Properties
    
    static let sharedController = AppFlowController()
    private var rootPathStep:PathStep?
    private var rootNavigationController:UINavigationController?
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Setup

    // co jak itemy maja te same nazwy? dawaj jakis fatal error
    // universal linki do tego
    // co jak chce pokazac ten sam ekran ale z innej sciezki?
    // animacje przejscia naprzod i w tyl
    // parametry
    // custom transition
    // modal vs push
    // przy pushu zeby nie tworzyl na nowo poprzednich vcs
    
    func prepare(forWindow window:UIWindow) {
        self.rootNavigationController = UINavigationController()
        window.rootViewController = rootNavigationController
    }
    
    func register(path:AppFlowControllerItem) {
        register(pathArray:[path])
    }
    
    func register(pathArray:[AppFlowControllerItem]) {
        
        var previousStep:PathStep?
        
        for path in pathArray {
            if let found = rootPathStep?.search(item: path) {
                previousStep = found
                continue
            } else {
                if let previousStep = previousStep {
                    previousStep.add(item: path)
                } else {
                    rootPathStep = PathStep(item: path)
                }
            }
        }
        
    }
    
    func show(item:AppFlowControllerItem) {
        if let found = rootPathStep?.search(item: item) {
            
            var items:[AppFlowControllerItem] = rootPathStep?.itemsFrom(step: found) ?? []
            let currentViewControllers = rootNavigationController?.viewControllers ?? []
            let numberOfVCToPop = max(0, currentViewControllers.count - items.count)
            var numberOfDeleted = 0
            
            for (index, item) in items.enumerated() {
                if index < currentViewControllers.count {
                    if currentViewControllers[index].isKind(of: item.viewControllerType) {
                        items.remove(at: index - numberOfDeleted)
                        numberOfDeleted += 1
                    }
                }
            }
            
            if numberOfVCToPop > 0 {
                // >=1 to pop
                let currentViewControllersCount = currentViewControllers.count
                let targetViewControllerIndex = max(0, currentViewControllersCount - numberOfVCToPop - 1)
                if let targetViewController = rootNavigationController?.viewControllers[targetViewControllerIndex] {
                    rootNavigationController?.popToViewController(targetViewController, animated: true)
                }
            } else if items.count == 1 {
                // 1 to push
                rootNavigationController?.pushViewController(items.first!.viewController, animated: true)
            } else if items.count > 1 {
                // >1 to push
                rootNavigationController?.pushViewController(items.last!.viewController, animated: true)
                let insertIndex = max(0, (rootNavigationController?.viewControllers.count ?? 0) - 1)
                let insertCount = items.count - 1
                let insertItems = items.prefix(insertCount)
                rootNavigationController?.viewControllers.insert(contentsOf: insertItems.map({ $0.viewController }), at: insertIndex)
            }
            
        } else {
            print("AppFlowController: Unregistered path for item \(item.name)")
        }
    }
}
