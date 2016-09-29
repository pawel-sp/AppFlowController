//
//  AppFlowControllerItem.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

protocol AppFlowControllerItem {
    
    var name:String { get }
    var viewController:UIViewController { get }
    var viewControllerType: UIViewController.Type { get }
    var forwardTransition:AppFlowControllerForwardTransition? { get set }
    var backwardTransition:AppFlowControllerBackwardTransition? { get set }
    
    func isEqual(item:AppFlowControllerItem) -> Bool
    
}

extension AppFlowControllerItem {
    
    func isEqual(item:AppFlowControllerItem) -> Bool {
        return self.name == item.name
    }
    
}
