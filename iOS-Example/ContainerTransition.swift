//
//  ContainerTransition.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 27.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class ContainerTransition: NSObject, AppFlowControllerTransition {
    
    // MARK: - AppFlowControllerTransition
    
    func forwardTransitionBlock(animated: Bool, completionBlock: @escaping () -> ()) -> AppFlowControllerForwardTransition.TransitionBlock {
        return { navigationController, viewController in
            if let containerViewController = navigationController.topViewController as? ContainerViewControllerInterface {
                containerViewController.addChildViewController(viewController)
                containerViewController.containerView.addSubview(viewController.view)
            }
            completionBlock()
        }
    }
    
    func backwardTransitionBlock(animated: Bool, completionBlock: @escaping () -> ()) -> AppFlowControllerBackwardTransition.TransitionBlock {
        return { viewController in
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
            completionBlock()
        }
    }

}

class PushToContainerTransition: PushPopAppFlowControllerTransition {
    
    override func forwardTransitionBlock(animated: Bool, completionBlock: @escaping () -> ()) -> AppFlowControllerForwardTransition.TransitionBlock {
        return { navigationController, viewController in
            navigationController.pushViewController(viewController, animated: animated)
            viewController.view.layoutSubviews()
            completionBlock()
        }
    }
    
}

