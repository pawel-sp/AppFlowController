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
    var viewControllersIncludingModal:[UIViewController] {
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
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping (() -> ())) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool, completion: @escaping (() -> ())) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let vc = popViewController(animated: animated)
        CATransaction.commit()
        return vc
    }
    
    var activeNavigationController:UINavigationController {
        return visibleViewController?.navigationController ?? self
    }
    
}