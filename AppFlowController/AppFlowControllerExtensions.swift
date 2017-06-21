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
    
    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    @discardableResult
    public func popViewController(animated: Bool, completion: (() -> ())?) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let vc = popViewController(animated: animated)
        CATransaction.commit()
        return vc
    }
    
    public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: (() -> ())?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        setViewControllers(viewControllers, animated: animated)
        CATransaction.commit()
    }
    
    
    public var visibleNavigationController:UINavigationController {
        return visibleViewController?.navigationController ?? self
    }
    
    static func new<T:UINavigationController>(with rootViewController: UIViewController, navigationBarClass: Swift.AnyClass?) -> T {
        if let navigationBarClass = navigationBarClass {
            let result = T(navigationBarClass: navigationBarClass, toolbarClass: nil)
            result.viewControllers = [rootViewController]
            return result
        } else {
            return T(rootViewController: rootViewController)
        }
    }
    
}

extension UIViewController {
    
    public var topPresentedViewController: UIViewController? {
        var presentedVC = presentedViewController
        while presentedVC?.presentedViewController != nil {
            presentedVC = presentedVC?.presentedViewController
        }
        return presentedVC
    }
    
    public func dismissAllPresentedViewControllers(completionBlock:(()->())?) {
        if let vc = topPresentedViewController {
            vc.dismiss(animated: false) { [weak self] in
                self?.dismissAllPresentedViewControllers(completionBlock: completionBlock)
            }
        } else {
            completionBlock?()
        }
    }
    
}
