//
//  AppFlowController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit



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
    private var lastSelectedItem:AppFlowControllerItem?
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Setup

    // universal linki do tego
    // animacje przejscia naprzod i w tyl
    // custom transition
    // push no modalu?
    // kolejne ekrany po parametrach
    // kilka parametrow
    // podziel na pliki
    // dodaj info ze nie mozna pokazac details bez parametru!
    // go back
    // klasa bazowa dla uinavigationcontroller'a dla modali
    // pomijanie defaultowych transition?
    // modal na modalu?
    // side menu?
    // go back
    
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
    
    // MARK: - Navigation
    
    func show(item:AppFlowControllerItem) {
        if let found = rootPathStep?.search(item: item), let rootNavigationController = rootNavigationController {
            
            var items:[AppFlowControllerItem] = rootPathStep?.itemsFrom(step: found) ?? []
            let currentViewControllers = rootNavigationController.viewControllers + (rootNavigationController.presentedViewController != nil ? [rootNavigationController.presentedViewController!] : [])
            let numberOfVCToDismiss = max(0, currentViewControllers.count - items.count)
            var numberOfDeleted = 0
            
            for (index, item) in items.enumerated() {
                if index < currentViewControllers.count {
                    if currentViewControllers[index].isKind(of: item.viewControllerType) {
                        items.remove(at: index - numberOfDeleted)
                        numberOfDeleted += 1
                    }
                }
            }
            
            if numberOfVCToDismiss > 0, let lastSelectedItem = lastSelectedItem {
                
                // >=1 to dismiss
                if let presentingViewController = rootNavigationController.visibleViewController?.presentingViewController {
                    // modal
                    if let modalNavigationController = presentingViewController as? UINavigationController {
                        lastSelectedItem.backwardTransition?.backwardTransitionBlock(animated: true)(rootNavigationController, modalNavigationController)
                    }
                }
                let currentViewControllersCount = currentViewControllers.count
                let targetViewControllerIndex   = max(0, currentViewControllersCount - numberOfVCToDismiss - 1)
                let targetViewController        = rootNavigationController.viewControllers[targetViewControllerIndex]
                let lastSelectedItemParent      = rootPathStep?.search(item: lastSelectedItem)?.parent?.current
                
                lastSelectedItemParent?.backwardTransition?.backwardTransitionBlock(animated: true)(rootNavigationController, targetViewController)
                
            } else if let item = items.first, items.count == 1 {
                
                // 1 to push/present
                let viewController = item.viewControllerBlock()
                if rootNavigationController.viewControllers.count == 0 {
                    rootNavigationController.viewControllers = [viewController]
                } else {
                    item.forwardTransition?.forwardTransitionBlock(animated: rootNavigationController.viewControllers.count > 0)(rootNavigationController, viewController)
                }
 
            } else if items.count > 1 {
                
                // >1 to push/present
                if let lastItem = items.last {
                    let viewController = lastItem.viewControllerBlock()
                    lastItem.forwardTransition?.forwardTransitionBlock(animated: rootNavigationController.viewControllers.count > 0)(rootNavigationController, viewController)
                    let insertIndex = max(0, rootNavigationController.viewControllers.count - 1)
                    let insertCount = items.count - 1
                    let insertItems = items.prefix(insertCount)
                    rootNavigationController.viewControllers.insert(contentsOf: insertItems.map({ $0.viewControllerBlock() }), at: insertIndex)
                }
                
            } else {
                assert(false, "AppFlowController: Internal error")
            }
            
            self.lastSelectedItem = item
            
        } else {
            assert(false, "AppFlowController: Unregistered path for item \(item.name)")
        }
    }

}

extension UIViewController {
    
    func setParameter(_ parameter:String?) {}
    
}
