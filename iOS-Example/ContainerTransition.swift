//
//  ContainerTransition.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 27.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class ContainerTransition: FlowTransition {
    
    // MARK: - Properties
    
    let loadPage: Bool
    
    // MARK: - Init
    
    init(loadPage: Bool) {
        self.loadPage = loadPage
    }
    
    convenience init() {
        self.init(loadPage: false)
    }
    
    // MARK: - FlowTransition
    
    public func shouldPreloadViewController() -> Bool {
        return loadPage
    }
    
    public func preloadViewController(_ viewController: UIViewController, from parentViewController: UIViewController)  {
        if let containerViewController = parentViewController as? ContainerViewControllerInterface {
            containerViewController.addChildViewController(viewController)
            (containerViewController as? UIViewController)?.view.layoutSubviews() // it's necessary - without it view doesnt exists yet
            containerViewController.containerView.addSubview(viewController.view)
        }
    }
    
    func performForwardTransition(animated: Bool, completion: @escaping () -> ()) -> ForwardTransition.ForwardTransitionAction {
        return { navigationController, viewController in
            if let containerViewController = navigationController.topViewController as? ContainerViewControllerInterface {
                containerViewController.addChildViewController(viewController)
                containerViewController.containerView.addSubview(viewController.view)
            }
            completion()
        }
    }
    
    func performBackwardTransition(animated: Bool, completion: @escaping () -> ()) -> BackwardTransition.BackwardTransitionAction {
        return { viewController in
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
            completion()
        }
    }

}

