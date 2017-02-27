//
//  AppFlowControllerExtensions.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 30.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    // that property assumes that every modal view controller gonna be presented from navigation controller (not from visible view controller)
    // it doesn't contain additional navigation controllers
    public var viewControllersIncludingModal:[UIViewController] {
        if let presentedViewController = presentedViewController {
            if let navigationPresenterViewController = presentedViewController as? UINavigationController {
                return viewControllers + navigationPresenterViewController.viewControllersIncludingModal
            } else {
                return viewControllers + [presentedViewController]
            }
        } else {
            return viewControllers
        }
    }
    
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping (() -> ())) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    public func popViewController(animated: Bool, completion: @escaping (() -> ())) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let vc = popViewController(animated: animated)
        CATransaction.commit()
        return vc
    }
    
    var activeNavigationController:UINavigationController {
        return visibleViewController?.navigationController ?? self
    }
    
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: @escaping (() -> ())) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        setViewControllers(viewControllers, animated: animated)
        CATransaction.commit()
    }
    
    var topPresentedViewController: UIViewController? {
        var presentedVC:UIViewController? = presentedViewController
        
        while presentedVC?.presentedViewController != nil {
            presentedVC = presentedVC?.presentedViewController
        }
        
        return presentedVC
    }
    
    func dismissAllPresentedViewControllers(completionBlock:(()->())?) {
        if let vc = topPresentedViewController {
            vc.dismiss(animated: false) { [weak self] in
                self?.dismissAllPresentedViewControllers(completionBlock: completionBlock)
            }
        } else {
            completionBlock?()
        }
    }
    
}
