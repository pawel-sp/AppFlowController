//
//  UIViewController+AFC.swift
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

extension UIViewController {
    open var topPresentedViewController: UIViewController? {
        var presentedVC = presentedViewController
        while presentedVC?.presentedViewController != nil {
            presentedVC = presentedVC?.presentedViewController
        }
        return presentedVC
    }
    
    @objc open func dismissAllPresentedViewControllers(completion: (()->())?) {
        if let vc = topPresentedViewController {
            vc.dismiss(animated: false) { [weak self] in
                self?.dismissAllPresentedViewControllers(completion: completion)
            }
        } else {
            completion?()
        }
    }
    
    var visible: UIViewController {
        if let tabBarController = self as? UITabBarController {
            return tabBarController.viewControllers?[tabBarController.selectedIndex].visible ?? self
        } else if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.visible ?? self
        } else {
            return self
        }
    }
}
