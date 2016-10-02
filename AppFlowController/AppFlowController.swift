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
    
    // MARK: - Enums
    
    enum AppFlowControllerError:Error {
        
        case pathNameAlreadyRegistered(name:String)
        case internalError
        case unregisteredPathName(name:String)
        case pageNotSavedAfterPresentation(name:String)
        
        var errorInfo:String {
            switch self {
                case .pathNameAlreadyRegistered(let name):
                    return "\(name) is already registered, if you want to register the same UIViewController for presenting it in a different way you need to create separate AppFlowControllerItem case with the same UIViewController"
                case .internalError:
                    return "Internal error"
                case .unregisteredPathName(let name):
                    return "Unregistered path for item \(name)"
                case .pageNotSavedAfterPresentation(let name):
                    return "\(name) not registered after presentation - internal error"
            }
        }
        
    }
    
    // MARK: - Properties (public)
    
    public static let sharedController = AppFlowController()
    
    // MARK: - Properties (private)
    
    private var rootPathStep:PathStep?
    private var rootNavigationController:UINavigationController?
    private var viewControllerNamesTable = NSMapTable<UIViewController,AnyObject>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)
    
    // MARK: - Init
    
    private init() {}
    
    // MARK: - Setup

    // TODO: custom transition
    // TODO: tab menu?
    // TODO: parameters
    
    public func prepare(forWindow window:UIWindow, rootNavigationControllerClass:UINavigationController.Type = UINavigationController.self) {
        self.rootNavigationController = rootNavigationControllerClass.init()
        window.rootViewController = rootNavigationController
    }
    
    public func register(path:AppFlowControllerItem) {
        register(path:[path])
    }
    
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
        if let found = rootPathStep?.search(item: item), let rootNavigationController = rootNavigationController {
            
            var items:[AppFlowControllerItem] = rootPathStep?.itemsFrom(step: found) ?? []
            let currentViewControllers        = rootNavigationController.viewControllersIncludingModal
            let numberOfVCToDismiss           = max(0, currentViewControllers.count - items.count)
            var numberOfDeleted               = 0
            
            for (index, item) in items.enumerated() {
                if index < currentViewControllers.count {
                    if currentViewControllers[index].isKind(of: item.viewControllerType) {
                        items.remove(at: index - numberOfDeleted)
                        numberOfDeleted += 1
                    }
                }
            }
            
            if numberOfVCToDismiss > 0 {

                // >1 to dismiss
                dismissItem(numberVCToDismiss: numberOfVCToDismiss, animated: animated)
                
            } else if let item = items.first, items.count == 1 {
                
                // 1 to push/present
                let viewController = item.viewControllerBlock()
                if rootNavigationController.viewControllers.count == 0 {
                    rootNavigationController.viewControllers = [viewController]
                } else {
                    let navigationController = rootNavigationController.activeNavigationController
                    item.forwardTransition?.forwardTransitionBlock(animated: navigationController.viewControllers.count > 0 && animated){}(navigationController, viewController)
                }
                
                viewControllerNamesTable.setObject(item.name as AnyObject?, forKey: viewController)
 
            } else if items.count > 1 {
                
                // >1 to push/present
                let currentViewControllersCount = rootNavigationController.viewControllers.count

                func presentItem(fromIndex index:Int) {
                    let navigationController = rootNavigationController.activeNavigationController
                    let item                 = items[index]
                    let viewController       = item.viewControllerBlock()
                    let animated             = currentViewControllersCount != 0 && animated
                    item.forwardTransition?.forwardTransitionBlock(animated: animated){
                        if index < items.count - 1 {
                            presentItem(fromIndex: index + 1)
                        }
                        self.viewControllerNamesTable.setObject(item.name as AnyObject?, forKey: viewController)
                    }(navigationController, viewController)
                }
                
                if currentViewControllersCount == 0 {
                    rootNavigationController.viewControllers = [items.first!.viewControllerBlock()]
                    presentItem(fromIndex: 1)
                } else {
                    presentItem(fromIndex: 0)
                }
                
            } else {
                assertError(error: .internalError)
            }
            
        } else {
            assertError(error: .unregisteredPathName(name: item.name))
        }
    }
    
    public func goBack(animated:Bool = true) {
        dismissItem(numberVCToDismiss: 1, animated: animated)
    }
    
    // MARK: - Private 
    
    fileprivate func dismissItem(numberVCToDismiss:Int, animated:Bool) {
        if let rootNavigationController = rootNavigationController {
            let navigationController      = rootNavigationController.activeNavigationController
            let visibleViewController     = navigationController.visibleViewController
            let visibleViewControllerName = viewControllerNamesTable.object(forKey: visibleViewController) as? String
            if let viewController = visibleViewController, let name = visibleViewControllerName, let visibleStep = rootPathStep?.search(forName: name) {
                visibleStep.current.backwardTransition?.backwardTransitionBlock(animated: animated){
                    if numberVCToDismiss - 1 > 0 {
                        self.dismissItem(numberVCToDismiss: numberVCToDismiss - 1, animated: animated)
                    }
                }(navigationController, viewController)
            } else {
                assertError(error: .pageNotSavedAfterPresentation(name: visibleViewControllerName ?? ""))
            }
        }
    }

    fileprivate func assertError(error:AppFlowControllerError) {
        assert(false, "AppFlowController: \(error.errorInfo)")
    }
    
}
