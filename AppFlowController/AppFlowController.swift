//
//  AppFlowController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 22.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

public class AppFlowController {

    // MARK: - Classes
    
    private class PathStep {
        
        let current:AppFlowControllerItem
        var children:[PathStep] = []
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
        
        func search(forName name:String) -> PathStep? {
            if self.current.name == name {
                return self
            } else {
                for child in children {
                    if let found = child.search(forName: name) {
                        return found
                    }
                }
                return nil
            }
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
    }
    
    // MARK: - Enums
    
    enum AppFlowControllerError:Error {
        
        case pathNameAlreadyRegistered(name:String)
        case internalError
        case unregisteredPathName(name:String)
        case missingConfigurationForAppFlowController
        
        var errorInfo:String {
            switch self {
                case .pathNameAlreadyRegistered(let name):
                    return "\(name) is already registered, if you want to register the same UIViewController for presenting it in a different way you need to create separate AppFlowControllerItem case with the same UIViewController"
                case .internalError:
                    return "Internal error"
                case .unregisteredPathName(let name):
                    return "Unregistered path for item \(name)"
                case .missingConfigurationForAppFlowController:
                    return "You need to invoke prepare(forWindow:UIWindow) function first"
            }
        }
        
    }
    
    // MARK: - Properties (public)
    
    public static let sharedController = AppFlowController()
    
    // MARK: - Properties (private)
    
    private var rootPathStep:PathStep?
    private var rootNavigationController:UINavigationController?
    private var viewControllerForNamesTable = NSMapTable<AnyObject,UIViewController>(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Setup

    // TODO: tab menu? default tab bar transition
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
                if let previousStep = previousStep {
                    previousStep.add(item: element)
                } else {
                    rootPathStep = PathStep(item: element)
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
                        let children            = step.children
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
    
    // MARK: - Private
 
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
