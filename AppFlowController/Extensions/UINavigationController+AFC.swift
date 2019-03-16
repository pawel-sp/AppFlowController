//
//  UINavigationController+AFC.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 30.09.2016.
//  Copyright (c) 2017 Paweł Sporysz
//  https://github.com/pawel-sp/AppFlowController
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
    @objc open func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    @discardableResult
    @objc open func popViewController(animated: Bool, completion: (() -> ())?) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let vc = popViewController(animated: animated)
        CATransaction.commit()
        return vc
    }
    
    @objc open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: (() -> ())?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        setViewControllers(viewControllers, animated: animated)
        CATransaction.commit()
    }
    
    open var visibleNavigationController: UINavigationController {
        return visibleViewController?.navigationController ?? self
    }
}
