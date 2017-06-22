//
//  AppFlowControllerTracker.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 11.10.2016.
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
    
    func register(viewController:UIViewController?, forKey key:String, skipped:Bool = false) {
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
        return items.filter({ $0.key == key }).first?.value.skipped ?? false 
    }
    
    func disableSkip(forKey key:String) {
        items.filter({ $0.key == key }).first?.value.skipped = false
    }
    
}
