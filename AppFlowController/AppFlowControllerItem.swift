//
//  AppFlowControllerItem.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 29.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

public typealias AppFlowControllerItemName = String

public protocol AppFlowControllerItem {
    
    var name:AppFlowControllerItemName { get }
    var viewControllerBlock:() -> UIViewController { get }
    var viewControllerType: UIViewController.Type { get }
    var forwardTransition:AppFlowControllerForwardTransition? { get set }
    var backwardTransition:AppFlowControllerBackwardTransition? { get set }
    
    func isEqual(item:AppFlowControllerItem) -> Bool
    
}

extension AppFlowControllerItem {
    
    public func isEqual(item:AppFlowControllerItem) -> Bool {
        return self.name == item.name
    }
    
}

open class AppFlowControllerPage: NSObject, AppFlowControllerItem {
    
    // MARK: - Properties
    
    public var name:String
    public var viewControllerBlock: () -> UIViewController
    public var viewControllerType: UIViewController.Type
    public var forwardTransition: AppFlowControllerForwardTransition?
    public var backwardTransition: AppFlowControllerBackwardTransition?
    
    // MARK: - Init
    
    public init(
        name:String,
        viewControllerBlock:@escaping ()->(UIViewController),
        viewControllerType:UIViewController.Type
    ) {
        self.name                = name
        self.viewControllerBlock = viewControllerBlock
        self.viewControllerType  = viewControllerType
    }
    
    public convenience init(
        name:String,
        storyboardName:String,
        viewControllerIdentifier:String,
        viewControllerType:UIViewController.Type
    ) {
        self.init(
            name: name,
            viewControllerBlock:{ UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: viewControllerIdentifier) },
            viewControllerType:viewControllerType
        )
    }
    
    public convenience init(
        name:String,
        storyboardName:String,
        viewControllerType:UIViewController.Type
    ) {
        self.init(
            name:name,
            storyboardName:storyboardName,
            viewControllerIdentifier:String(describing: viewControllerType),
            viewControllerType:viewControllerType
        )
    }
    
}
