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
    
    private(set) var rootPathStep:PathStep?
    private(set) var tracker = Tracker()
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Setup
    
    public func prepare(for window:UIWindow, rootNavigationController:UINavigationController = UINavigationController()) {
        self.rootNavigationController = rootNavigationController
        window.rootViewController = rootNavigationController
    }
    
    public func register(path:AppFlowControllerPage) throws {
        try register(path:[path])
    }
    
    public func register(path:[AppFlowControllerPage]) throws {
        if let lastPath = path.last, !lastPath.supportVariants, rootPathStep?.search(page: lastPath) != nil {
            throw AppFlowControllerError.pathAlreadyRegistered(identifier: lastPath.identifier)
        }
        
        var previousStep:PathStep?
        
        for var element in path {
            if let found = rootPathStep?.search(page: element) {
                previousStep = found
                continue
            } else {
                if let previous = previousStep {
                    if element.supportVariants {
                        element.variantName = previous.current.identifier
                    }
                    previousStep = previous.add(page: element)
                } else {
                    rootPathStep = PathStep(page: element)
                    previousStep = rootPathStep
                }
            }
        }
    }
    
    public func register(path:[[AppFlowControllerPage]]) throws {
        for subpath in path {
            try register(path: subpath)
        }
    }
    
    // MARK: - Navigation
    
    open func show(item:AppFlowControllerPage, variant:AppFlowControllerPage? = nil, parameters:[AppFlowControllerParameter]? = nil, animated:Bool = true, skipDismissTransitions:Bool = false, skipItems:[AppFlowControllerPage]? = nil) {
        
        var item = item
        
        if item.supportVariants && variant == nil {
            assertError(error: .missingVariant(identifier: item.identifier))
        }
        
        if !item.supportVariants && variant != nil {
            assertError(error: .variantNotSupported(identifier: item.identifier))
        }
        
        if item.supportVariants && variant != nil {
            item.variantName = variant?.identifier
        }
        
        guard let foundStep = rootPathStep?.search(page: item) else {
            assertError(error: .unregisteredPathIdentifier(identifier: item.identifier))
            return
        }
        
        guard let rootNavigationController = rootNavigationController else {
            assertError(error: .missingConfigurationForAppFlowController)
            return
        }
        
        let newItems         = rootPathStep?.allParentPages(from: foundStep) ?? []
        let currentStep      = visibleStep()
        let currentItems     = currentStep == nil ? [] : (rootPathStep?.allParentPages(from: currentStep!) ?? [])
        
        if let currentStep = currentStep {
            let distance                = PathStep.distanceBetween(step: currentStep, and: foundStep)
            let dismissCounter          = distance.up
            let _                       = distance.down
            let dismissRange:Range<Int> = dismissCounter == 0 ? 0..<0 : (currentItems.count - dismissCounter) ..< currentItems.count
            let displayRange:Range<Int> = 0 ..< newItems.count
            dismiss(items: currentItems, fromIndexRange: dismissRange, animated: animated, skipTransition: skipDismissTransitions) {
                self.register(parameters:parameters)
                self.tracker.disableSkip(for: item.identifier)
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
                if let identifier = parent?.current.identifier {
                    viewController = tracker.viewController(for: identifier)
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
    
    public func popToItem(_ item:AppFlowControllerPage) {
        guard let navigationController = rootNavigationController?.visibleNavigationController else {
            return
        }
        guard let targetViewController = tracker.viewController(for: item.identifier) else {
            return
        }
        navigationController.popToViewController(targetViewController, animated: true)
    }
    
    // When you need present view controller in different way then using AppFlowController you need to register that view controller right after presenting that to keep structure of AppFlowController.
    // TODO: - what about variants?
    public func register(viewController:UIViewController, forPathName pathName:String) {
        if let _ = rootPathStep?.search(identifier: pathName) {
            self.tracker.register(viewController: viewController, for: pathName)
        } else {
            assertError(error: AppFlowControllerError.unregisteredPathIdentifier(identifier: pathName))
        }
    }
    
    open func pathComponents(forItem item:AppFlowControllerPage) -> String? {
        
        guard let foundStep = rootPathStep?.search(page: item) else {
            assertError(error: .unregisteredPathIdentifier(identifier: item.identifier))
            return nil
        }
        
        let items       = rootPathStep?.allParentPages(from: foundStep) ?? []
        let itemStrings = items.map({ $0.identifier })
        
        return itemStrings.joined(separator: "/")
    }
    
    open func currentPathComponents() -> String? {
        if let visibleStep = visibleStep() {
            let items       = rootPathStep?.allParentPages(from: visibleStep) ?? []
            let itemStrings = items.map({ $0.identifier })
            return itemStrings.joined(separator: "/")
        } else {
            return nil
        }
    }
    
    open func currentItem() -> AppFlowControllerPage? {
        return visibleStep()?.current
    }
    
    open func parameterForCurrentItem() -> String? {
        if let currentItemID = currentItem()?.identifier {
            return tracker.parameter(for: currentItemID)
        } else {
            return nil
        }
    }
    
    // Use it when there is no visible item yet
    open func parameterForItem(item:AppFlowControllerPage, variant:AppFlowControllerPage? = nil) -> String? {
        var item = item
        item.variantName = variant?.identifier
        return tracker.parameter(for: item.identifier)
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
        if let visibleViewController = navigationController?.visibleViewController, let key = tracker.key(for: visibleViewController) {
            return rootPathStep?.search(identifier: key)
        } else {
            return nil
        }
    }
    
    private func viewController(fromItem item:AppFlowControllerPage) -> UIViewController {
        let viewController = item.viewControllerBlock()
        if (viewController.isKind(of: UITabBarController.self)) {
            if let step = rootPathStep?.search(page: item) {
                let children            = step.children
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
    
    private func register(parameters:[AppFlowControllerParameter]?) {
        if let parameters = parameters {
            for parameter in parameters {
                self.tracker.register(parameter: parameter.value, for: parameter.identifier)
            }
        }
    }
    
    private func display(items:[AppFlowControllerPage], fromIndexRange indexRange:Range<Int>, animated:Bool, skipItems:[AppFlowControllerPage]? = nil, completionBlock:(() -> ())?) {
        
        let index      = indexRange.lowerBound
        let item       = items[index]
        let identifier = item.identifier
        
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
                if item.forwardTransition is PushPopAppFlowControllerTransition {
                    viewControllersToPush += [item]
                } else {
                    break
                }
            }
            let viewControllers = viewControllersToPush.map({ self.viewController(fromItem: $0) })
            for (index, viewController) in viewControllers.enumerated() {
                let identifier = viewControllersToPush[index].identifier
                tracker.register(viewController: viewController, for: identifier)
            }
            navigationController.setViewControllers(viewControllers, animated: false) {
                displayNextItem(range: indexRange, animated: false, offset:max(0, viewControllersToPush.count - 1))
            }
        } else if tracker.viewController(for: item.identifier) == nil && !tracker.isItemSkipped(at: item.identifier) {
            
            let shouldSkipViewController = skipItems?.contains(where: { $0.identifier == item.identifier }) == true
            
            if shouldSkipViewController {
                
                tracker.register(viewController: nil, for: item.identifier, skipped:shouldSkipViewController)
                displayNextItem(range: indexRange, animated: animated)
                
            } else {
                
                let viewController = self.viewController(fromItem:item)
                tracker.register(viewController: viewController, for: item.identifier, skipped:shouldSkipViewController)
                item.forwardTransition?.forwardTransitionBlock(animated: animated){
                    displayNextItem(range: indexRange, animated: animated)
                }(navigationController, viewController)
            }
    
        } else {
            
            displayNextItem(range: indexRange, animated: animated)
            
        }
    }
    
    private func dismiss(items:[AppFlowControllerPage], fromIndexRange indexRange:Range<Int>, animated:Bool, skipTransition:Bool = false, completionBlock:(() -> ())?) {
        if indexRange.count == 0 {
            
            completionBlock?()
            
        } else {
            
            let index = indexRange.upperBound - 1
            let item  = items[index]
            
            guard let viewController = tracker.viewController(for: item.identifier) else {
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
        assert(false, "AppFlowController: \(error.localizedDescription)")
    }
    
}
