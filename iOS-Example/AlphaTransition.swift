//
//  AlphaTransition.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 02.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class AlphaTransition: NSObject, UIViewControllerAnimatedTransitioning, FlowTransition, UINavigationControllerDelegate {

    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        let containerView = transitionContext.containerView
        guard let toView = toVC.view else { return }
        guard let fromView = fromVC.view else { return }
        let animationDuration = transitionDuration(using: transitionContext)
        
        toView.alpha = 0
        containerView.addSubview(toView)
        UIView.animate(withDuration: animationDuration, animations: {
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
    
    // MARK: - FlowTransition
    
    func performForwardTransition(animated: Bool, completion: @escaping () -> ()) -> ForwardTransition.ForwardTransitionAction {
        return { navigationController, viewController in
            let previousDelegate = navigationController.delegate
            navigationController.delegate = self
            navigationController.pushViewController(viewController, animated: animated){
                navigationController.delegate = previousDelegate
                completion()
            }
        }
    }
    
    func performBackwardTransition(animated: Bool, completion: @escaping () -> ()) -> BackwardTransition.BackwardTransitionAction {
        return { viewController in
            let navigationController = viewController.navigationController
            let previousDelegate = navigationController?.delegate
            navigationController?.delegate = self
            let _ = navigationController?.popViewController(animated: animated) {
                navigationController?.delegate = previousDelegate
                completion()
            }
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
}
