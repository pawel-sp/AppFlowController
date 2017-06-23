//
//  FakeNavigationController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit

class FakeNavigationController: UINavigationController {

    override func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        viewControllers.append(viewController)
        completion?()
    }
    
    override func popViewController(animated: Bool, completion: (() -> ())?) -> UIViewController? {
        let result = viewControllers.removeLast()
        completion?()
        return result
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool, completion: (() -> ())?) {
        self.viewControllers = viewControllers
        completion?()
    }
    
}
