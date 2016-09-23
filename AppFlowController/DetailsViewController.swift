//
//  DetailsViewController.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    var colorParameter:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let parameter = colorParameter, let color = Color.colorFromString(parameter) {
            view.backgroundColor = color.uicolor
        }
    }
    
    override func setParameter(_ parameter: String?) {
        super.setParameter(parameter)
        self.colorParameter = parameter
    }

}
