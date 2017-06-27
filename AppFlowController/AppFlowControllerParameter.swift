//
//  AppFlowControllerParameter.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
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
