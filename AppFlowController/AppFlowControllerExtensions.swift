//
//  AppFlowControllerExtensions.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 30.09.2016.
//  Copyright (c) 2017 Paweł Sporysz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
