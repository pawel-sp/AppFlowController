//
//  AppFlowController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

open class AppFlowController {
    
    // MARK: - Properties
    
    public static let shared = AppFlowController()
    
    private var rootPathStep:PathStep?
    private var rootNavigationController:UINavigationController?
    private var tracker = AppFlowControllerTracker()
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Setup
    
    public func prepare(forWindow window:UIWindow, rootNavigationControllerClass:UINavigationController.Type = UINavigationController.self) {
        self.rootNavigationController = rootNavigationControllerClass.init()
        window.rootViewController = rootNavigationController
    }
    
    public func register(path:AppFlowControllerItem) {
        register(path:[path])
    }
    
    // If you are using custom transition you need to remember to use it in every path where specific path step exists (look at example)
    public func register(path:[AppFlowControllerItem]) {
        
        if let lastPath = path.last, rootPathStep?.search(item: lastPath) != nil {
            assertError(error: .pathNameAlreadyRegistered(name: lastPath.name))
        }
        
        var previousStep:PathStep?
        
        for element in path {
            if let found = rootPathStep?.search(item: element) {
                previousStep = found
                continue
            } else {
                if let previous = previousStep {
                    previousStep = previous.add(item: element)
                } else {
                    rootPathStep = PathStep(item: element)
                    previousStep = rootPathStep
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // parameters need to keys equals item names to have correct behaviour.
    open func show(item:AppFlowControllerItem, parameters:[AppFlowControllerItemName:String]? = nil, animated:Bool = true, skipDismissTransitions:Bool = false) {
        
        var itemToPresent = item
        
        if let transferItem = item as? AppFlowControllerTransferItem {
            if let currentItem = currentItem() {
                itemToPresent = transferItem.transferBlock(currentItem)
            } else {
                assertError(error: .cannotUseTransferItemWithoutVisiblePage)
            }
        }
        
        guard let foundStep = rootPathStep?.search(item: itemToPresent) else {
            assertError(error: .unregisteredPathName(name: itemToPresent.name))
            return
        }
        
        guard let rootNavigationController = rootNavigationController else {
            assertError(error: .missingConfigurationForAppFlowController)
            return
        }
        
        let newItems     = rootPathStep?.allParentItems(fromStep: foundStep) ?? []
        let currentStep  = visibleStep()
        let currentItems = currentStep == nil ? [] : (rootPathStep?.allParentItems(fromStep: currentStep!) ?? [])
        
        if let currentStep = currentStep {
            let distance                = rootPathStep?.distanceBetween(step: currentStep, andStep: foundStep)
            let dismissCounter          = distance?.up   ?? 0
            let _                       = distance?.down ?? 0
            let dismissRange:Range<Int> = dismissCounter == 0 ? 0..<0 : (currentItems.count - dismissCounter) ..< currentItems.count
            let displayRange:Range<Int> = 0 ..< newItems.count
            dismiss(items: currentItems, fromIndexRange: dismissRange, animated: animated, skipTransition: skipDismissTransitions) {
                self.register(parameters:parameters)
                self.display(items: newItems, fromIndexRange: displayRange, animated: animated, completionBlock: nil)
            }
        } else {
            rootNavigationController.viewControllers.removeAll()
            register(parameters:parameters)
            display(items: newItems, fromIndexRange: 0..<newItems.count, animated: animated, completionBlock: nil)
        }
    }
    
    public func goBack(animated:Bool = true) {
        if
            let visible = visibleStep(),
            let parent = visible.parent,
            let viewController = tracker.viewController(forKey: parent.current.name),
            let navigationController = rootNavigationController?.activeNavigationController {
            
            visible.current.backwardTransition?.backwardTransitionBlock(animated: animated){}(navigationController, viewController)
        }
    }
    
    public func popToItem(_ itemitem:AppFlowControllerItem) {
        guard let navigationController = rootNavigationController?.activeNavigationController else {
            return
        }
        guard let targetViewController = tracker.viewController(forKey: item.name) else {
            return
        }
        navigationController.popToViewController(targetViewController, animated: true)
    }
    
    // When you need present view controller in different way then using AppFlowController you need to register that view controller right after presenting that to keep structure of AppFlowController.
    public func register(viewController:UIViewController, forPathName pathName:String) {
        if let _ = rootPathStep?.search(forName: pathName) {
            self.tracker.register(viewController: viewController, forKey: pathName)
        } else {
            assertError(error: AppFlowControllerError.unregisteredPathName(name: pathName))
        }
    }
    
    open func pathComponents(forItem item:AppFlowControllerItem) -> String? {
        
        guard let foundStep = rootPathStep?.search(item: item) else {
            assertError(error: .unregisteredPathName(name: item.name))
            return nil
        }
        
        let items       = rootPathStep?.allParentItems(fromStep: foundStep) ?? []
        let itemStrings = items.map({ $0.name })
        
        return itemStrings.joined(separator: "/")
    }
    
    open func currentPathComponents() -> String? {
        if let visibleStep = visibleStep() {
            let items       = rootPathStep?.allParentItems(fromStep: visibleStep) ?? []
            let itemStrings = items.map({ $0.name })
            return itemStrings.joined(separator: "/")
        } else {
            return nil
        }
    }
    
    open func currentItem() -> AppFlowControllerItem? {
        return visibleStep()?.current
    }
    
    open func parameterForCurrentItem() -> String? {
        if let currentItemName = currentItem()?.name {
            return tracker.parameter(forKey: currentItemName)
        } else {
            return nil
        }
    }
    
    // Use it when there is no visible item yet
    open func parameterForItem(item:AppFlowControllerItem) -> String? {
        return tracker.parameter(forKey: item.name)
    }
    
    open func reset() {
        rootNavigationController?.viewControllers.removeAll()
        tracker.reset()
    }
    
    // MARK: - Helpers
    
    private func visibleStep() -> PathStep? {
        let navigationController  = rootNavigationController?.activeNavigationController
        if let visibleViewController = navigationController?.visibleViewController, let key = tracker.key(forViewController: visibleViewController) {
            return rootPathStep?.search(forName: key)
        } else {
            return nil
        }
    }
    
    private func viewController(fromItem item:AppFlowControllerItem) -> UIViewController {
        let viewController = item.viewControllerBlock()
        if (viewController.isKind(of: UITabBarController.self)) {
            if let step = rootPathStep?.search(item: item) {
                let children            = step.getChildren()
                let tabBarController    = viewController as! UITabBarController
                let tabsViewControllers = children.map({ $0.current.viewControllerBlock() })
                tabBarController.viewControllers = tabsViewControllers
                return tabBarController
            } else {
                return viewController
            }
        } else {
            return viewController
        }
    }
    
    private func register(parameters:[AppFlowControllerItemName : String]?) {
        if let parameters = parameters {
            for (key, value) in parameters {
                self.tracker.register(parameter: value, forKey: key)
            }
        }
    }
    
    private func display(items:[AppFlowControllerItem], fromIndexRange indexRange:Range<Int>, animated:Bool, completionBlock:(() -> ())?) {
        
        let index = indexRange.lowerBound
        let item  = items[index]
        let name  = item.name
        
        guard let navigationController = rootNavigationController?.activeNavigationController else {
            completionBlock?()
            return
        }
        
        func displayNextItem(range:Range<Int>, animated:Bool, offset:Int = 0) {
            let newRange:Range<Int> = (range.lowerBound + 1 + offset) ..< range.upperBound
            if newRange.count == 0 {
                completionBlock?()
            } else {
                self.display(
                    items: items,
                    fromIndexRange: newRange,
                    animated: animated,
                    completionBlock: completionBlock
                )
            }
        }
        
        if navigationController.viewControllers.count == 0 {
            var viewControllersToPush = [item]
            for item in items[1..<items.count] {
                if item.forwardTransition?.isKind(of: PushPopAppFlowControllerTransition.self) == true {
                    viewControllersToPush += [item]
                } else {
                    break
                }
            }
            let viewControllers = viewControllersToPush.map({ self.viewController(fromItem: $0) })
            for (index, viewController) in viewControllers.enumerated() {
                let name = viewControllersToPush[index].name
                tracker.register(viewController: viewController, forKey: name)
            }
            navigationController.setViewControllers(viewControllers, animated: false) {
                displayNextItem(range: indexRange, animated: false, offset:max(0, viewControllersToPush.count - 1))
            }
        } else if tracker.viewController(forKey: item.name) == nil {
            
            let viewController = self.viewController(fromItem:item)
            tracker.register(viewController: viewController, forKey: item.name)
            
            item.forwardTransition?.forwardTransitionBlock(animated: animated){
                displayNextItem(range: indexRange, animated: animated)
                }(navigationController, viewController)
            
        } else {
            
            displayNextItem(range: indexRange, animated: animated)
            
        }
    }
    
    private func dismiss(items:[AppFlowControllerItem], fromIndexRange indexRange:Range<Int>, animated:Bool, skipTransition:Bool = false, completionBlock:(() -> ())?) {
        if indexRange.count == 0 {
            
            completionBlock?()
            
        } else {
            
            let index = indexRange.upperBound - 1
            let item  = items[index]
            
            guard let viewController = tracker.viewController(forKey: item.name) else {
                completionBlock?()
                return
            }
            guard let navigationController = rootNavigationController?.activeNavigationController else {
                completionBlock?()
                return
            }
            
            if !skipTransition {
                item.backwardTransition?.backwardTransitionBlock(animated: animated){
                    self.dismiss(
                        items: items,
                        fromIndexRange: indexRange.lowerBound..<indexRange.upperBound - 1,
                        animated: animated,
                        skipTransition: skipTransition,
                        completionBlock: completionBlock
                    )
                    }(navigationController, viewController)
            } else {
                self.dismiss(
                    items: items,
                    fromIndexRange: indexRange.lowerBound..<indexRange.upperBound - 1,
                    animated: animated,
                    skipTransition: skipTransition,
                    completionBlock: completionBlock
                )
            }
            
        }
    }
    
    private func assertError(error:AppFlowControllerError) {
        assert(false, "AppFlowController: \(error.errorInfo)")
    }
    
}
