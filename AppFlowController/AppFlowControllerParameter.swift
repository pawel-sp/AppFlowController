//
//  AppFlowControllerParameter.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
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

import Foundation

public struct AppFlowControllerParameter {
    
    // MARK: - Properties
    
    public let page:AppFlowControllerPage
    public let variant:AppFlowControllerPage?
    public let value:String
    
    /**
        Identifier of page. For not nil variant it has variant name prefix.
    */
    public var identifier:String {
        var page = self.page
        page.variantName = variant?.identifier
        return page.identifier
    }
    
    // MARK: - Init
    
    /**
        Creates new instance of AppFlowControllerParameter.
     
        - Parameter page:    Page associated with parameter
        - Parameter variant: Parent page according to registration path. Use it only if page supports variants.
        - Parameter value:   Value of parameter.
    */
    public init(page:AppFlowControllerPage, variant:AppFlowControllerPage? = nil, value:String) {
        self.page    = page
        self.variant = variant
        self.value   = value
    }
    
}
