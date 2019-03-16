//
//  MockViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 21.06.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit

class MockViewController: UIViewController {
    var dismissParams: (Bool)?
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissParams = (flag)
        completion?()
    }
}
