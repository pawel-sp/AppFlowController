//
//  AppFlowControllerPage.swift
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

public struct AppFlowControllerPage {
    
    // MARK: - Properties
    
    public let name:String
    public let supportVariants: Bool
    public let viewControllerBlock: () -> UIViewController
    public let viewControllerType: UIViewController.Type
    
    public internal(set) var forwardTransition: AppFlowControllerForwardTransition?
    public internal(set) var backwardTransition: AppFlowControllerBackwardTransition?
    
    public internal(set) var variantName:String?
    
    public var identifier:String {
        if let variant = variantName {
            return "\(variant)_\(name)"
        } else {
            return name
        }
    }
    
    // MARK: - Init
    
    public init(
        name:String,
        supportVariants:Bool = false,
        viewControllerBlock:@escaping ()->(UIViewController),
        viewControllerType:UIViewController.Type
    ) {
        self.name                = name
        self.supportVariants     = supportVariants
        self.viewControllerBlock = viewControllerBlock
        self.viewControllerType  = viewControllerType
    }
    
    public init(
        name:String,
        supportVariants:Bool = false,
        storyboardName:String,
        storyboardInitBlock:@escaping ((String)->UIStoryboard) = { UIStoryboard(name: $0, bundle: nil) },
        viewControllerIdentifier:String,
        viewControllerType:UIViewController.Type
    ) {
        self.init(
            name: name,
            supportVariants: supportVariants,
            viewControllerBlock:{ storyboardInitBlock(storyboardName).instantiateViewController(withIdentifier: viewControllerIdentifier) },
            viewControllerType:viewControllerType
        )
    }
    
    public init(
        name:String,
        supportVariants:Bool = false,
        storyboardName:String,
        storyboardInitBlock:@escaping ((String)->UIStoryboard) = { UIStoryboard(name: $0, bundle: nil) },
        viewControllerType:UIViewController.Type
    ) {
        self.init(
            name:name,
            supportVariants:supportVariants,
            storyboardName:storyboardName,
            storyboardInitBlock:storyboardInitBlock,
            viewControllerIdentifier:String(describing: viewControllerType),
            viewControllerType:viewControllerType
        )
    }

}

extension AppFlowControllerPage: Equatable {
    
    public static func ==(lhs:AppFlowControllerPage, rhs:AppFlowControllerPage) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.supportVariants == rhs.supportVariants &&
            lhs.viewControllerType == rhs.viewControllerType &&
            (lhs.forwardTransition?.isEqual(rhs.forwardTransition) == true || lhs.forwardTransition == nil && rhs.forwardTransition == nil ) &&
            (lhs.backwardTransition?.isEqual(rhs.backwardTransition) == true || lhs.backwardTransition == nil && rhs.backwardTransition == nil) &&
            lhs.variantName == rhs.variantName
    }
    
}
