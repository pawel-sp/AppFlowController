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
    var isModal:Bool { get }
    
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

    // universal linki do tego
    // animacje przejscia naprzod i w tyl
    // parametry
    // custom transition
    // push no modalu?
    // go back?
    
    func prepare(forWindow window:UIWindow) {
        self.rootNavigationController = UINavigationController()
        window.rootViewController = rootNavigationController
    }
    
    func register(path:AppFlowControllerItem) {
        register(path:[path])
    }
    
    func register(path:[AppFlowControllerItem]) {
        
        if let lastPath = path.last, rootPathStep?.search(item: lastPath) != nil {
            assert(false, "AppFlowController: \(lastPath.name) is already registered, if you want to register the same UIViewController for presenting it in a different way you need to create separate AppFlowControllerItem case with the same UIViewController")
        }
        
        var previousStep:PathStep?
        
        for element in path {
            if let found = rootPathStep?.search(item: element) {
                previousStep = found
                continue
            } else {
                if let previousStep = previousStep {
                    previousStep.add(item: element)
                } else {
                    rootPathStep = PathStep(item: element)
                }
            }
        }
        
    }
    
    func show(item:AppFlowControllerItem) {
        if let found = rootPathStep?.search(item: item), let rootNavigationController = rootNavigationController {
            
            var items:[AppFlowControllerItem] = rootPathStep?.itemsFrom(step: found) ?? []
            let currentViewControllers = rootNavigationController.viewControllers + (rootNavigationController.presentedViewController != nil ? [rootNavigationController.presentedViewController!] : [])
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
                if let presentingViewController = rootNavigationController.visibleViewController?.presentingViewController {
                    // modal
                    presentingViewController.dismiss(animated: true, completion: nil)
                }
                let currentViewControllersCount = currentViewControllers.count
                let targetViewControllerIndex = max(0, currentViewControllersCount - numberOfVCToPop - 1)
                let targetViewController = rootNavigationController.viewControllers[targetViewControllerIndex]
                rootNavigationController.popToViewController(targetViewController, animated: true)
            } else if let item = items.first, items.count == 1 {
                // 1 to push/present
                if item.isModal {
                    rootNavigationController.present(item.viewController, animated: true, completion: nil)
                } else {
                    rootNavigationController.pushViewController(item.viewController, animated: true)
                }
            } else if items.count > 1 {
                // >1 to push/present
                if let lastItem = items.last {
                    let completionBlock = {
                        let insertIndex = max(0, rootNavigationController.viewControllers.count - (lastItem.isModal ? 0 : 1))
                        let insertCount = items.count - 1
                        let insertItems = items.prefix(insertCount)
                        rootNavigationController.viewControllers.insert(contentsOf: insertItems.map({ $0.viewController }), at: insertIndex)
                    }
                    if lastItem.isModal {
                        if currentViewControllers.count == 0 {
                            completionBlock()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                rootNavigationController.present(lastItem.viewController, animated: true, completion: nil)
                            }
                        } else {
                            rootNavigationController.present(lastItem.viewController, animated: true, completion: completionBlock)
                        }
                    } else {
                        rootNavigationController.pushViewController(lastItem.viewController, animated: true)
                        completionBlock()
                    }
                }
            }
            
        } else {
            print("AppFlowController: Unregistered path for item \(item.name)")
        }
    }
}
