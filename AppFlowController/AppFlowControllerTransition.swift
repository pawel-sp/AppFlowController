//
//  AppFlowControllerTransition.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
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

// MARK: - Protocols

public protocol AppFlowControllerForwardTransition: NSObjectProtocol {
    
    typealias TransitionBlock = (UINavigationController, UIViewController) -> Void
    
    func shouldPreloadViewController() -> Bool
    func preloadViewController(_ viewController:UIViewController, from parentViewController:UIViewController)
    func configureViewController(from viewController:UIViewController) -> UIViewController
    func forwardTransitionBlock(animated:Bool, completionBlock:@escaping ()->()) -> TransitionBlock
    
}

public protocol AppFlowControllerBackwardTransition: NSObjectProtocol {
    
    typealias TransitionBlock = (UIViewController) -> Void
    
    func backwardTransitionBlock(animated:Bool, completionBlock:@escaping()->()) -> TransitionBlock
    
}

public protocol AppFlowControllerTransition: AppFlowControllerForwardTransition, AppFlowControllerBackwardTransition {}

extension AppFlowControllerTransition {
    
    public func configureViewController(from viewController:UIViewController) -> UIViewController {
        return viewController
    }
    
    public func shouldPreloadViewController() -> Bool {
        return false
    }
    
    public func preloadViewController(_ viewController:UIViewController, from parentViewController:UIViewController)  {}

}

// MARK: - Classes

open class PushPopAppFlowControllerTransition: NSObject, AppFlowControllerTransition {
    
    // MARK: - Properties
    
    public static let `default` = PushPopAppFlowControllerTransition()
    
    // MARK: - AppFlowControllerForwardTransition

    open func forwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> AppFlowControllerForwardTransition.TransitionBlock {
        return { navigationController, viewController in
            navigationController.pushViewController(viewController, animated: animated, completion:completionBlock)
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    open func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> AppFlowControllerBackwardTransition.TransitionBlock {
        return { viewController in
            viewController.navigationController?.popViewController(animated: animated, completion: completionBlock)
        }
    }
    
}

open class ModalAppFlowControllerTransition<T:UINavigationController>: NSObject, AppFlowControllerTransition {
    
    // MARK: - AppFlowControllerForwardTransition
    
    open func configureViewController(from viewController:UIViewController) -> UIViewController {
        return T.init(rootViewController: viewController)
    }
    
    open func forwardTransitionBlock(animated: Bool, completionBlock:@escaping ()->()) -> AppFlowControllerForwardTransition.TransitionBlock {
        return { navigationController, viewController in
            navigationController.present(viewController, animated: animated, completion: completionBlock)
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    open func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> AppFlowControllerBackwardTransition.TransitionBlock {
        return { viewController in
            viewController.dismiss(animated: animated, completion: completionBlock)
        }
    }
    
}

open class DefaultModalAppFlowControllerTransition: ModalAppFlowControllerTransition<UINavigationController> {
    
    // MARK: - Properties
    
    public static let `default` = DefaultModalAppFlowControllerTransition()
    
}

open class TabBarAppFlowControllerTransition<T:UINavigationController>: NSObject, AppFlowControllerTransition {
    
    // MARK: - AppFlowControllerForwardTransition
    
    open func shouldPreloadViewController() -> Bool {
        return true
    }
    
    open func preloadViewController(_ viewController:UIViewController, from parentViewController:UIViewController)  {
        if let tabBarController = parentViewController as? UITabBarController {
            var currentViewControllers = tabBarController.viewControllers ?? []
            currentViewControllers.append(viewController)
            tabBarController.viewControllers = currentViewControllers
        }
    }
    
    open func configureViewController(from viewController:UIViewController) -> UIViewController {
        return T.init(rootViewController: viewController)
    }
    
    open func forwardTransitionBlock(animated: Bool, completionBlock:@escaping ()->()) -> AppFlowControllerForwardTransition.TransitionBlock {
        return { navigationController, viewController in
            if
                let tabBarController = navigationController.parent as? UITabBarController,
                let index = tabBarController.viewControllers?.index(of: viewController.navigationController ?? viewController)
            {
                tabBarController.selectedIndex = index
            }
            completionBlock()
        }
    }
    
    // MARK: - AppFlowControllerBackwardTransition
    
    open func backwardTransitionBlock(animated: Bool, completionBlock:@escaping()->()) -> AppFlowControllerBackwardTransition.TransitionBlock {
        return { viewController in
            completionBlock()
        }
    }
    
}

open class DefaultTabBarAppFlowControllerTransition: TabBarAppFlowControllerTransition<UINavigationController> {
    
    // MARK: - Properties
    
    public static let `default` = DefaultTabBarAppFlowControllerTransition()
    
}
