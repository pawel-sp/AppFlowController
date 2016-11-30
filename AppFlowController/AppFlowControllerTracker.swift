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
        var parameter:String?
        var skipped:Bool
        
        // MARK: - Init
        
        init(viewController:UIViewController?, parameter:String?, skipped:Bool = false) {
            self.viewController = viewController
            self.parameter      = parameter
            self.skipped        = skipped
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
    
    func register(viewController:UIViewController, forKey key:String, skipped:Bool = false) {
        if let found = items[key] {
            found.viewController = viewController
            found.skipped        = skipped
        } else {
            items[key] = Item(viewController: viewController, parameter: nil, skipped: skipped)
        }
    }
    
    func register(parameter:String?, forKey key:String) {
        if let found = items[key] {
            found.parameter = parameter
        } else {
            items[key] = Item(viewController: nil, parameter: parameter)
        }
    }
    
    func disableSkipped(forKey key:String) {
        items[key]?.skipped = false
    }
    
    func viewController(forKey key:String) -> UIViewController? {
        return items[key]?.viewController
    }
    
    func key(forViewController viewController:UIViewController) -> String? {
        let filtered = items.filter({ $0.value.viewController === viewController })
        return filtered.first?.key
    }
    
    func parameter(forKey key:String) -> String? {
        return items[key]?.parameter
    }
    
    func isKeyRegistered(key:String) -> Bool {
        return items.contains(where: { $0.key == key })
    }
    
    func isItemAtKeySkipped(key:String) -> Bool {
        return items.filter({ $0.key == key }).first?.value.skipped == true
    }
    
}
