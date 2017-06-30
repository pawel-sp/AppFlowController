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
    
    // MARK: - Properties
    
    let loadPage:Bool
    
    // MARK: - Init
    
    init(loadPage:Bool) {
        self.loadPage = loadPage
        super.init()
    }
    
    convenience override init() {
        self.init(loadPage: false)
    }
    
    // MARK: - AppFlowControllerTransition
    
    public func shouldPreloadViewController() -> Bool {
        return loadPage
    }
    
    public func preloadViewController(_ viewController:UIViewController, from parentViewController:UIViewController)  {
        if let containerViewController = parentViewController as? ContainerViewControllerInterface {
            containerViewController.addChildViewController(viewController)
            (containerViewController as? UIViewController)?.view.layoutSubviews() // it's necessary - without it view doesnt exists yet
            containerViewController.containerView.addSubview(viewController.view)
        }
    }
    
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

