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
    
    public static let sharedController = AppFlowController()
    
    private var rootPathStep:PathStep?
    private var rootNavigationController:UINavigationController?
    private var tracker = AppFlowControllerTracker()
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Setup

    // TODO: parameters
    // TODO: skipping view controllers during transition
    
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
    
    open func show(item:AppFlowControllerItem, parameters:[AppFlowControllerItemName:String]? = nil, animated:Bool = true) {
        
        guard let foundStep = rootPathStep?.search(item: item) else {
            assertError(error: .unregisteredPathName(name: item.name))
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
            dismiss(items: currentItems, fromIndexRange: dismissRange, animated: animated) {
                self.display(items: newItems, fromIndexRange: displayRange, animated: animated, parameters: parameters, completionBlock: nil)
            }
        } else {
            rootNavigationController.viewControllers.removeAll()
            display(items: newItems, fromIndexRange: 0..<newItems.count, animated: animated, parameters: parameters, completionBlock: nil)
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
    
    // When you need present view controller in different way then using AppFlowController you need to register that view controller right after presenting that to keep structure of AppFlowController.
    public func register(viewController:UIViewController, forPathName pathName:String) {
        if let _ = rootPathStep?.search(forName: pathName) {
            self.tracker.register(viewController: viewController, parameters: nil, forKey: pathName)
        } else {
            assertError(error: AppFlowControllerError.unregisteredPathName(name: pathName))
        }
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
    
    private func display(items:[AppFlowControllerItem], fromIndexRange indexRange:Range<Int>, animated:Bool, parameters:[AppFlowControllerItemName:String]?, completionBlock:(() -> ())?) {
        
        let item = items[indexRange.lowerBound]
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
                    parameters: parameters,
                    completionBlock: completionBlock
                )
            }
        }
        
        if navigationController.viewControllers.count == 0 {
            let viewControllersToPush = [item] + items.filter({ $0.forwardTransition?.isKind(of: PushPopAppFlowControllerTransition.self) == true })
            let viewControllers       = viewControllersToPush.map({ self.viewController(fromItem: $0) })
            navigationController.setViewControllers(viewControllers, animated: false) {
                for (index, viewController) in viewControllers.enumerated() {
                    let name = viewControllersToPush[index].name
                    self.tracker.register(viewController: viewController, parameters: nil, forKey: name)
                }
                displayNextItem(range: indexRange, animated: false, offset:max(0, viewControllersToPush.count - 1))
            }
        } else if tracker.viewController(forKey: item.name) == nil {
            
            let viewController = self.viewController(fromItem:item)
            item.forwardTransition?.forwardTransitionBlock(animated: animated){
                self.tracker.register(viewController: viewController, parameters: nil, forKey: item.name)
                displayNextItem(range: indexRange, animated: animated)
            }(navigationController, viewController)
            
        } else {
            
            displayNextItem(range: indexRange, animated: animated)
            
        }
    }
    
    private func dismiss(items:[AppFlowControllerItem], fromIndexRange indexRange:Range<Int>, animated:Bool, completionBlock:(() -> ())?) {
        if indexRange.count == 0 {
            
            completionBlock?()
            
        } else {
            
            let item = items[indexRange.upperBound - 1]
            guard let viewController = tracker.viewController(forKey: item.name) else {
                completionBlock?()
                return
            }
            guard let navigationController = rootNavigationController?.activeNavigationController else {
                completionBlock?()
                return
            }
            
            item.backwardTransition?.backwardTransitionBlock(animated: animated){
                self.dismiss(
                    items: items,
                    fromIndexRange: indexRange.lowerBound..<indexRange.upperBound - 1,
                    animated: animated,
                    completionBlock: completionBlock
                )
            }(navigationController, viewController)
            
        }
    }

    private func assertError(error:AppFlowControllerError) {
        assert(false, "AppFlowController: \(error.errorInfo)")
    }
    
}
