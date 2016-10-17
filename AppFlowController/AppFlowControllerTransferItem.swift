//
//  AppFlowControllerTransferItem.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 17.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

protocol AppFlowControllerTransferItem: AppFlowControllerItem {
    
    var transferBlock:(AppFlowControllerItem)->(AppFlowControllerItem) { get }
    
}

open class AppFlowControllerTransferPage: AppFlowControllerPage, AppFlowControllerTransferItem {
    
    // MARK: - Properties
    
    public var transferBlock:(AppFlowControllerItem)->(AppFlowControllerItem)
    
    // MARK: - Init
    
    public init(
        transferBlock:@escaping (AppFlowControllerItem)->(AppFlowControllerItem)
    ) {
        self.transferBlock = transferBlock
        super.init(name: "transfer_page", viewControllerBlock: { UIViewController() }, viewControllerType: UIViewController.self)
    }
    
}

