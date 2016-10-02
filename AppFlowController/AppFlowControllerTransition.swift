//
//  AppFlowControllerTransition.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

public protocol AppFlowControllerForwardTransition {
    
    func forwardTransitionBlock(animated:Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void
    
}

public protocol AppFlowControllerBackwardTransition {
    
    func backwardTransitionBlock(animated:Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void
    
}

public protocol AppFlowControllerTransition:AppFlowControllerForwardTransition, AppFlowControllerBackwardTransition{
    
}

public let DefaultPushPopAppFlowControllerTransition = PushPopAppFlowControllerTransition()
public let DefaultModalFlowControllerTransition      = ModalAppFlowControllerTransition()

public class PushPopAppFlowControllerTransition:AppFlowControllerTransition {
    
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

public class ModalAppFlowControllerTransition:AppFlowControllerTransition {
    
    // MARK: - Properties
    
    public var navigationControllerClass:UINavigationController.Type {
        return UINavigationController.self
    }
    
    // MARK: - AppFlowControllerForwardTransition
    
    public func forwardTransitionBlock(animated: Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            if viewController.navigationController == nil {
                let modalNavigationController = self.navigationControllerClass.init(rootViewController: viewController)
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
