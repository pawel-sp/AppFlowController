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
    
    public var identifier:String {
        var page = self.page
        page.variantName = variant?.identifier
        return page.identifier
    }
    
    // MARK: - Init
    
    public init(page:AppFlowControllerPage, variant:AppFlowControllerPage? = nil, value:String) {
        self.page    = page
        self.variant = variant
        self.value   = value
    }
    
}
