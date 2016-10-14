//
//  AppFlowControllerTransition.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

public protocol AppFlowControllerForwardTransition:NSObjectProtocol {
    
    func forwardTransitionBlock(animated:Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void
    
}

public protocol AppFlowControllerBackwardTransition:NSObjectProtocol {
    
    func backwardTransitionBlock(animated:Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void
    
}

public protocol AppFlowControllerTransition:AppFlowControllerForwardTransition, AppFlowControllerBackwardTransition{
    
}

public let DefaultPushPopAppFlowControllerTransition              = PushPopAppFlowControllerTransition()
public let DefaultModalAppFlowControllerTransition                = ModalAppFlowControllerTransition()
public let DefaultTabBarControllerPageAppFlowControllerTransition = TabBarControllerPageTransition()

public class PushPopAppFlowControllerTransition:NSObject, AppFlowControllerTransition {
    
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

public class ModalAppFlowControllerTransition<T:UINavigationController>:NSObject, AppFlowControllerTransition {
    
    // MARK: - AppFlowControllerForwardTransition
    
    public func forwardTransitionBlock(animated: Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            if viewController.navigationController == nil {
                let modalNavigationController = T.init(rootViewController: viewController)
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

public class TabBarControllerPageTransition:NSObject, AppFlowControllerTransition {
    
    // MARK: - AppFlowControllerForwardTransition
    
    public func forwardTransitionBlock(animated: Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            if let tabBarController = navigationController.topViewController as? UITabBarController {
                if let found = tabBarController.viewControllers?.filter({ $0.isKind(of: type(of: viewController)) }).first {
                    let index = tabBarController.viewControllers?.index(of: found) ?? 0
                    tabBarController.selectedIndex = index
                }
            } else {
                DefaultPushPopAppFlowControllerTransition.forwardTransitionBlock(animated: animated, completionBlock: completionBlock)(navigationController, viewController)
            }
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    public func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            
        }
    }
    
}
