//
//  AppFlowController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

public class AppFlowController {
    
    // MARK: - Properties (public)
    
    public static let sharedController = AppFlowController()
    
    // MARK: - Properties (private)
    
    private var rootPathStep:PathStep?
    private var rootNavigationController:UINavigationController?
    private var viewControllerForNamesTable = NSMapTable<AnyObject,UIViewController>(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
    
    // MARK: - Init
    
    private init() {}
    
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
    
    public func show(item:AppFlowControllerItem, animated:Bool = true) {
        
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
        
        func displayItems(fromIndex index:Int, fromItems items:[AppFlowControllerItem], animated:Bool, completionBlock:@escaping ()->()) {
            
            let item                 = items[index]
            let navigationController = rootNavigationController.activeNavigationController
            
            func displayNextItemIfNeeded(animated:Bool) {
                if index + 1 < items.count {
                    displayItems(fromIndex: index + 1, fromItems: items, animated:animated, completionBlock: completionBlock)
                } else {
                    completionBlock()
                }
            }
            
            func itemViewController(item:AppFlowControllerItem) -> UIViewController {
                let vc = item.viewControllerBlock()
                if (vc.isKind(of: UITabBarController.self)) {
                    if let step = rootPathStep?.search(item: item) {
                        let children            = step.getChildren()
                        let tabBarController    = vc as! UITabBarController
                        let tabsViewControllers = children.map({ $0.current.viewControllerBlock() })
                        tabBarController.viewControllers = tabsViewControllers
                        return tabBarController
                    } else {
                        return vc
                    }
                } else {
                    return vc
                }
            }
            
            if navigationController.viewControllers.count == 0 {
                
                let viewController = itemViewController(item:item)
                navigationController.viewControllers = [viewController]
                viewControllerForNamesTable.setObject(viewController, forKey: item.name as AnyObject?)
                displayNextItemIfNeeded(animated:false)
                
            } else if viewControllerForNamesTable.object(forKey: item.name as AnyObject?) == nil {
            
                let viewController = itemViewController(item:item)
                item.forwardTransition?.forwardTransitionBlock(animated: animated){
                    self.viewControllerForNamesTable.setObject(viewController, forKey: item.name as AnyObject?)
                    displayNextItemIfNeeded(animated:animated)
                }(navigationController, viewController)
                
            } else {
                
                displayNextItemIfNeeded(animated:animated)
                
            }
            
        }
        
        func dismissItems(fromIndex:Int, toIndex:Int, fromItems items:[AppFlowControllerItem], completionBlock:@escaping ()->()) {
            
            let item                 = items[fromIndex]
            let viewController       = viewControllerForNamesTable.object(forKey: item.name as AnyObject?)
            let navigationController = rootNavigationController.activeNavigationController
            
            if fromIndex == toIndex {
                completionBlock()
            } else {
                if viewController != nil {
                    item.backwardTransition?.backwardTransitionBlock(animated: animated){
                        if fromIndex - 1 > toIndex {
                            dismissItems(fromIndex: fromIndex - 1, toIndex: toIndex, fromItems: items, completionBlock: completionBlock)
                        } else {
                            completionBlock()
                        }
                        }(navigationController, viewController!)
                } else {
                    completionBlock()
                }
            }

        }
        
        if let currentStep = currentStep {
            let test           = rootPathStep?.distanceBetween(step: currentStep, andStep: foundStep)
            let dismissCounter = test?.up ?? 0
            dismissItems(fromIndex: currentItems.count - 1, toIndex: currentItems.count - 1 - dismissCounter, fromItems: currentItems){
                displayItems(fromIndex: 0, fromItems: newItems, animated:animated){}
            }
        } else {
            displayItems(fromIndex: 0, fromItems: newItems, animated:animated){}
        }

    }
    
    public func goBack(animated:Bool = true) {
        if let visible = visibleStep(), let parent = visible.parent, let viewController = viewControllerForNamesTable.object(forKey: parent.current.name as AnyObject?), let navigationController = rootNavigationController?.activeNavigationController {
            visible.current.backwardTransition?.backwardTransitionBlock(animated: animated){}(navigationController, viewController)
        }
    }
    
    // MARK: - Helpers
 
    fileprivate func visibleStep() -> PathStep? {
        let navigationController  = rootNavigationController?.activeNavigationController
        let visibleViewController = navigationController?.visibleViewController
        let keysEnumerator        = viewControllerForNamesTable.keyEnumerator()
        for key in keysEnumerator {
            if let keyString = key as? String, viewControllerForNamesTable.object(forKey: key as AnyObject?) == visibleViewController {
                return rootPathStep?.search(forName: keyString)
            }
        }
        return nil
    }

    fileprivate func assertError(error:AppFlowControllerError) {
        assert(false, "AppFlowController: \(error.errorInfo)")
    }
    
}
