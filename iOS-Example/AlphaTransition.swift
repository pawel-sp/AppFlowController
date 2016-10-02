//
//  AlphaTransition.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 02.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class AlphaTransition: NSObject, UIViewControllerAnimatedTransitioning, AppFlowControllerTransition, UINavigationControllerDelegate {

    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC   = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        guard let toVC     = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        let containerView  = transitionContext.containerView
        guard let toView   = toVC.view else { return }
        guard let fromView = fromVC.view else { return }
        
        toView.alpha = 0
        containerView.addSubview(toView)
        UIView.animate(withDuration: 0.5, animations: {
            toView.alpha = 1
        }) { finished in
            if (transitionContext.transitionWasCancelled) {
                toView.removeFromSuperview()
            } else {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    // MARK: - AppFlowControllerTransition
    
    func backwardTransitionBlock(animated: Bool, completionBlock: @escaping () -> ()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            let previousDelegate = navigationController.delegate
            navigationController.delegate = self
            let _ = navigationController.popViewController(animated: animated) {
                navigationController.delegate = previousDelegate
                completionBlock()
            }
        }
    }
    
    func forwardTransitionBlock(animated: Bool, completionBlock: @escaping () -> ()) -> (UINavigationController, UIViewController) -> Void {
        return { navigationController, viewController in
            let previousDelegate = navigationController.delegate
            navigationController.delegate = self
            navigationController.pushViewController(viewController, animated: animated){
                navigationController.delegate = previousDelegate
                completionBlock()
            }
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
}