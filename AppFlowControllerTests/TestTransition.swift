//
//  TestTransition.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import AppFlowController

class TestTransition: NSObject, AppFlowControllerTransition {
    
    func forwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> AppFlowControllerForwardTransition.TransitionBlock {
        return { navigationController, viewController in
            navigationController.viewControllers.append(viewController)
            completionBlock()
        }
    }
    
    func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> AppFlowControllerBackwardTransition.TransitionBlock {
        return { viewcontroller in
            let navigationController = viewcontroller.navigationController
            if let index = navigationController?.viewControllers.index(of: viewcontroller) {
                navigationController?.viewControllers.remove(at: index)
            }
        }
    }
    
}
