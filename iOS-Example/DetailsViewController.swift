//
//  DetailsViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit
import AppFlowController

class DetailsViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(AppFlowController.sharedController.parameterForCurrentItem())
    }
    
}
