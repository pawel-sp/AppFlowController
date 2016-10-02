//
//  AppFlowControllerTransition.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

protocol AppFlowControllerForwardTransition {
    
    func forwardTransitionBlock(animated:Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void
    
}

protocol AppFlowControllerBackwardTransition {
    
    func backwardTransitionBlock(animated:Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void
    
}

protocol AppFlowControllerTransition:AppFlowControllerForwardTransition, AppFlowControllerBackwardTransition{
    
}

let DefaultPushPopAppFlowControllerTransition = PushPopAppFlowControllerTransition()
let DefaultModalFlowControllerTransition      = ModalAppFlowControllerTransition()

class PushPopAppFlowControllerTransition:AppFlowControllerTransition {
    
    // MARK: - AppFlowControllerForwardTransition
    
    func forwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            navigationController.pushViewController(viewController, animated: animated, completion:completionBlock)
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            let _ = navigationController.popViewController(animated: animated, completion: completionBlock)
        }
    }
    
}

class ModalAppFlowControllerTransition:AppFlowControllerTransition {
    
    // MARK: - AppFlowControllerForwardTransition
    
    func forwardTransitionBlock(animated: Bool, completionBlock:@escaping ()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            if viewController.navigationController == nil {
                let modalNavigationController = UINavigationController(rootViewController: viewController)
                navigationController.present(modalNavigationController, animated: animated, completion: completionBlock)
            } else {
                navigationController.present(viewController, animated: animated, completion: completionBlock)
            }
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            viewController.dismiss(animated: animated, completion: completionBlock)
        }
    }
    
}