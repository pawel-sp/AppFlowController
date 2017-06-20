//
//  AppFlowController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
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

import UIKit

open class AppFlowController {
    
    // MARK: - Properties
    
    public static let shared = AppFlowController()
    public var rootNavigationController:UINavigationController?
    
    private var rootPathStep:PathStep?
    private var tracker = AppFlowControllerTracker()
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Setup
    
    public func prepare(forWindow window:UIWindow, rootNavigationController:UINavigationController = UINavigationController()) {
        self.rootNavigationController = rootNavigationController
        window.rootViewController = rootNavigationController
    }
    
    public func register(path:AppFlowControllerItem) {
        register(path:[path])
    }
    
    public func register(path:[AppFlowControllerItem]) {
        register(path:[path])
    }
    
    // If you are using custom transition you need to remember to use it in every path where specific path step exists (look at example)
    public func register(path:[[AppFlowControllerItem]]) {
        
        for subpath in path {
            
            if let lastPath = subpath.last, !lastPath.supportVariants, rootPathStep?.search(item: lastPath) != nil {
                assertError(error: .pathNameAlreadyRegistered(name: lastPath.name))
            }
            
            var previousStep:PathStep?
            
            for var element in subpath {
                if let found = rootPathStep?.search(item: element) {
                    previousStep = found
                    continue
                } else {
                    if let previous = previousStep {
                        if element.supportVariants {
                            element.name = "\(previous.current.name)_\(element.name)"
                        }
                        previousStep = previous.add(item: element)
                    } else {
                        rootPathStep = PathStep(item: element)
                        previousStep = rootPathStep
                    }
                }
            }
        }
        
    }
    
    // MARK: - Navigation
    
    // parameters need to keys equals item names to have correct behaviour.
    // skipItems - those items won't be within view controllers stack! It's only for items to show, not to dismiss!
    open func show(item:AppFlowControllerItem, variant:AppFlowControllerItem? = nil, parameters:[AppFlowControllerItemName:String]? = nil, animated:Bool = true, skipDismissTransitions:Bool = false, skipItems:[AppFlowControllerItem]? = nil) {
        
        if item.supportVariants && variant == nil {
            assertError(error: .missingVariant(name: item.name))
        }
        
        if !item.supportVariants && variant != nil {
            assertError(error: .variantNotSupported(name: item.name))
        }
        
        guard let foundStep = rootPathStep?.search(item: item, parent:variant) else {
            assertError(error: .unregisteredPathName(name: item.name, variant: variant?.name))
            return
        }
        
        guard let rootNavigationController = rootNavigationController else {
            assertError(error: .missingConfigurationForAppFlowController)
            return
        }
        
        let newItems         = rootPathStep?.allParentItems(fromStep: foundStep) ?? []
        let currentStep      = visibleStep()
        let currentItems     = currentStep == nil ? [] : (rootPathStep?.allParentItems(fromStep: currentStep!) ?? [])
        
        if let currentStep = currentStep {
            let distance                = rootPathStep?.distanceBetween(step: currentStep, andStep: foundStep)
            let dismissCounter          = distance?.up   ?? 0
            let _                       = distance?.down ?? 0
            let dismissRange:Range<Int> = dismissCounter == 0 ? 0..<0 : (currentItems.count - dismissCounter) ..< currentItems.count
            let displayRange:Range<Int> = 0 ..< newItems.count
            dismiss(items: currentItems, fromIndexRange: dismissRange, animated: animated, skipTransition: skipDismissTransitions) {
                self.register(parameters:parameters)
                self.display(items: newItems, fromIndexRange: displayRange, animated: animated, skipItems: skipItems, completionBlock: nil)
            }
        } else {
            rootNavigationController.viewControllers.removeAll()
            tracker.reset()
            register(parameters:parameters)
            display(items: newItems, fromIndexRange: 0..<newItems.count, animated: animated, skipItems: skipItems, completionBlock: nil)
        }
    }
    
    public func goBack(animated:Bool = true) {
        if let visible = visibleStep() {
            
            var parent = visible.parent
            var viewController:UIViewController?
            let navigationController = rootNavigationController?.visibleNavigationController
            
            while viewController == nil {
                if let name = parent?.current.name {
                    viewController = tracker.viewController(forKey: name)
                } else {
                    break
                }
                parent = parent?.parent
            }
            
            if let viewController = viewController, let navigationController = navigationController {
                visible.current.backwardTransition?.backwardTransitionBlock(animated: animated){}(navigationController, viewController)
            }
        }
    }
    
    public func popToItem(_ item:AppFlowControllerItem) {
        guard let navigationController = rootNavigationController?.visibleNavigationController else {
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
            assertError(error: AppFlowControllerError.unregisteredPathName(name: pathName, variant: nil))
        }
    }
    
    open func pathComponents(forItem item:AppFlowControllerItem) -> String? {
        
        guard let foundStep = rootPathStep?.search(item: item) else {
            assertError(error: .unregisteredPathName(name: item.name, variant: nil))
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
    
    open func reset(completionBlock:(()->())?) {
        rootNavigationController?.dismissAllPresentedViewControllers() {
            self.rootNavigationController?.viewControllers.removeAll()
            self.tracker.reset()
            completionBlock?()
        }
    }
    
    // MARK: - Helpers
    
    private func visibleStep() -> PathStep? {
        let navigationController  = rootNavigationController?.visibleNavigationController
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
    
    private func display(items:[AppFlowControllerItem], fromIndexRange indexRange:Range<Int>, animated:Bool, skipItems:[AppFlowControllerItem]? = nil, completionBlock:(() -> ())?) {
        
        let index = indexRange.lowerBound
        let item  = items[index]
        let name  = item.name
        
        guard let navigationController = rootNavigationController?.visibleNavigationController else {
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
                    skipItems: skipItems,
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
        } else if tracker.viewController(forKey: item.name) == nil && !tracker.isItemAtKeySkipped(key: item.name) {
            
            let shouldSkipViewController = skipItems?.contains(where: { $0.isEqual(item: item) }) == true
            
            if shouldSkipViewController {
                
                tracker.register(viewController: nil, forKey: item.name, skipped:shouldSkipViewController)
                displayNextItem(range: indexRange, animated: animated)
                
            } else {
                
                let viewController = self.viewController(fromItem:item)
                tracker.register(viewController: viewController, forKey: item.name, skipped:shouldSkipViewController)
                item.forwardTransition?.forwardTransitionBlock(animated: animated){
                    displayNextItem(range: indexRange, animated: animated)
                }(navigationController, viewController)
            }
    
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
            guard let navigationController = rootNavigationController?.visibleNavigationController else {
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
