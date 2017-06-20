//
//  AppFlowControllerTransition.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
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
import Foundation

public protocol AppFlowControllerForwardTransition: NSObjectProtocol {
    
    func forwardTransitionBlock(animated:Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void
    
}

public protocol AppFlowControllerBackwardTransition: NSObjectProtocol {
    
    func backwardTransitionBlock(animated:Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void
    
}

public protocol AppFlowControllerTransition:AppFlowControllerForwardTransition, AppFlowControllerBackwardTransition{
    
}

public class PushPopAppFlowControllerTransition: NSObject, AppFlowControllerTransition {
    
    // MARK: - Properties
    
    public static let `default` = PushPopAppFlowControllerTransition()
    
    // MARK: - AppFlowControllerForwardTransition
    
    public func forwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            navigationController.pushViewController(viewController, animated: animated, completion:completionBlock)
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    public func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            let _ = navigationController.popViewController(animated: animated, completion: completionBlock)
        }
    }
    
}

public class ModalAppFlowControllerTransition<T:UINavigationController>: NSObject, AppFlowControllerTransition {
 
    // MARK: - Properties
    
    public let navigationBarClass:UINavigationBar.Type?
    
    // MARK: - Init
    
    public init(navigationBarClass:UINavigationBar.Type? = nil) {
        self.navigationBarClass = navigationBarClass
    }
    
    // MARK: - Utilities
    
    private func modalNavigationController<T:UINavigationController>(rootViewController: UIViewController) -> T {
        if let navigationBarClass = navigationBarClass {
            let navigationController = T.init(navigationBarClass: navigationBarClass, toolbarClass: nil)
            navigationController.viewControllers = [rootViewController]
            return navigationController
        } else {
            return T.init(rootViewController: rootViewController)
        }
    }
    
    // MARK: - AppFlowControllerForwardTransition
    
    public func forwardTransitionBlock(animated: Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            if viewController.navigationController == nil {
                let modalNavigationController:T = self.modalNavigationController(rootViewController: viewController)
                navigationController.present(modalNavigationController, animated: animated, completion: completionBlock)
            } else {
                navigationController.present(viewController, animated: animated, completion: completionBlock)
            }
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    public func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            viewController.dismiss(animated: animated, completion: completionBlock)
        }
    }
    
}

public class TabBarAppFlowControllerTransition: NSObject, AppFlowControllerTransition {
    
    // MARK: - Properties
    
    public static let `default` = TabBarAppFlowControllerTransition()
    
    // MARK: - AppFlowControllerForwardTransition
    
    public func forwardTransitionBlock(animated: Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            if let tabBarController = navigationController.topViewController as? UITabBarController {
                if let found = tabBarController.viewControllers?.filter({ $0.isKind(of: type(of: viewController)) }).first {
                    let index = tabBarController.viewControllers?.index(of: found) ?? 0
                    tabBarController.selectedIndex = index
                }
            } else {
                PushPopAppFlowControllerTransition.default.forwardTransitionBlock(animated: animated, completionBlock: completionBlock)(navigationController, viewController)
            }
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    public func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            
        }
    }
    
}
