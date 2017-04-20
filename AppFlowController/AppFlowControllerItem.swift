//
//  AppFlowControllerItem.swift
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
