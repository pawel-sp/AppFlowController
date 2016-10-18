//
//  AppFlowControllerTracker.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 11.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import Foundation

class AppFlowControllerTracker {

    // MARK: - Classes
    
    private class Item {
        
        // MARK: - Properties
        
        weak var viewController:UIViewController?
        var parameters:[AppFlowControllerItemName:String]?
        
        // MARK: - Init
        
        init(viewController:UIViewController, parameters:[AppFlowControllerItemName:String]?) {
            self.viewController = viewController
            self.parameters     = parameters
        }
        
    }
    
    // MARK: - Properties
    
    private var items:[String:Item] = [:]
    
    // MARK: - Init
    
    init() {}
    
    // MARK: - Utilities
    
    func reset() {
        items.removeAll()
    }
    
    func register(viewController:UIViewController, parameters: [AppFlowControllerItemName:String]?, forKey key:String) {
        items[key] = Item(viewController: viewController, parameters: parameters)
    }
    
    func viewController(forKey key:String) -> UIViewController? {
        return items[key]?.viewController
    }
    
    func key(forViewController viewController:UIViewController) -> String? {
        let filtered = items.filter({ $0.value.viewController === viewController })
        return filtered.first?.key
    }
    
    func parameters(forViewController viewController:UIViewController) -> [AppFlowControllerItemName:String]? {
        let filtered = items.filter({ $0.value.viewController === viewController })
        return filtered.first?.value.parameters
    }
    
}
