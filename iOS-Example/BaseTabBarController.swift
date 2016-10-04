//
//  BaseTabBarController.swift
//  iOS-Example
//
//  Created by Paweł Sporysz on 04.10.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    deinit {
        print("\(type(of:self)) deallocated")
    }
    
}
