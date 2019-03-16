//
//  FlowTransition.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
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

// MARK: - Protocols

public protocol ForwardTransition: AnyObject {
    typealias ForwardTransitionAction = (UINavigationController, UIViewController) -> Void
    
    /**
        Defines if previous view controller should load view controller from that transition. Default = false.
    */
    func shouldPreloadViewController() -> Bool
    
    /**
        Invokes only if shouldPreloadViewController() returns true. It invokes right before presenting previous view controller.
     
        - Parameter viewController:         Current view controller to present.
        - Parameter parentViewController:   Previous view controller. For exmaple if previous view controller is kind of UITabBarController you can use it to assign viewControllers.
    */
    func preloadViewController(_ viewController: UIViewController, from previousViewController: UIViewController)
    
    /**
        Invokes right before presenting view controller.
    */
    func configureViewController(from viewController: UIViewController) -> UIViewController
    
    
    /**
        Returns block which will be used to show view controller in it's navigation controller.
    */
    func performForwardTransition(animated: Bool, completion: @escaping ()->()) -> ForwardTransitionAction
    
}

public protocol BackwardTransition: AnyObject {
    typealias BackwardTransitionAction = (UIViewController) -> Void
    
    /**
        Returns block which gonna be used to dismiss view controller.
     */
    func performBackwardTransition(animated: Bool, completion: @escaping ()->()) -> BackwardTransitionAction
    
}

public protocol FlowTransition: ForwardTransition, BackwardTransition {}

extension FlowTransition {
    public func configureViewController(from viewController: UIViewController) -> UIViewController {
        return viewController
    }
    
    public func shouldPreloadViewController() -> Bool {
        return false
    }
    
    public func preloadViewController(_ viewController: UIViewController, from previousViewController: UIViewController) {}
}

// MARK: - Classes

open class PushPopFlowTransition: FlowTransition {
    
    // MARK: - Properties
    
    public static let `default` = PushPopFlowTransition()
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - ForwardTransition

    open func performForwardTransition(animated: Bool, completion: @escaping ()->()) -> ForwardTransition.ForwardTransitionAction {
        return { navigationController, viewController in
            navigationController.pushViewController(viewController, animated: animated, completion:completion)
        }
    }
    
    // MARK: - BackwardTransition
    
    open func performBackwardTransition(animated: Bool, completion: @escaping ()->()) -> BackwardTransition.BackwardTransitionAction {
        return { viewController in
            viewController.navigationController?.popViewController(animated: animated, completion: completion)
        }
    }
    
}

open class ModalFlowTransition<T: UINavigationController>: FlowTransition {
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - ForwardTransition
    
    open func configureViewController(from viewController: UIViewController) -> UIViewController {
        return T.init(rootViewController: viewController)
    }
    
    open func performForwardTransition(animated: Bool, completion: @escaping ()->()) -> ForwardTransition.ForwardTransitionAction {
        return { navigationController, viewController in
            navigationController.present(viewController, animated: animated, completion: completion)
        }
    }
    
    // MARK: - BackwardTransition
    
    open func performBackwardTransition(animated: Bool, completion: @escaping ()->()) -> BackwardTransition.BackwardTransitionAction {
        return { viewController in
            viewController.dismiss(animated: animated, completion: completion)
        }
    }
    
}

open class DefaultModalFlowTransition: ModalFlowTransition<UINavigationController> {
    public static let `default` = DefaultModalFlowTransition()
}

open class TabBarFlowTransition<T: UINavigationController>: FlowTransition {
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - ForwardTransition
    
    open func shouldPreloadViewController() -> Bool {
        return true
    }
    
    open func preloadViewController(_ viewController: UIViewController, from previousViewController: UIViewController)  {
        if let tabBarController = previousViewController as? UITabBarController {
            var currentViewControllers = tabBarController.viewControllers ?? []
            currentViewControllers.append(viewController)
            tabBarController.viewControllers = currentViewControllers
        }
    }
    
    open func configureViewController(from viewController: UIViewController) -> UIViewController {
        return T.init(rootViewController: viewController)
    }
    
    open func performForwardTransition(animated: Bool, completion: @escaping ()->()) -> ForwardTransition.ForwardTransitionAction {
        return { navigationController, viewController in
            if let tabBarController = navigationController.parent as? UITabBarController,
                let index = tabBarController.viewControllers?.index(of: viewController.navigationController ?? viewController) {
                tabBarController.selectedIndex = index
            }
            completion()
        }
    }
    
    // MARK: - BackwardTransition
    
    open func performBackwardTransition(animated: Bool, completion: @escaping ()->()) -> BackwardTransition.BackwardTransitionAction {
        return { _ in
            completion()
        }
    }
    
}

open class DefaultTabBarFlowTransition: TabBarFlowTransition<UINavigationController> {
    public static let `default` = DefaultTabBarFlowTransition()
}
