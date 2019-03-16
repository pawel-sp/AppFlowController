//
//  ColorsDataBase.swift
//  AppFlowController
//
//  Created by Paweł Sporysz on 23.09.2016.
//  Copyright © 2016 Paweł Sporysz. All rights reserved.
//

import UIKit

enum Color: String {
    case red   = "red"
    case blue  = "blue"
    case green = "green"
    
    var uicolor:UIColor {
        switch self {
            case .red:   return UIColor.red
            case .blue:  return UIColor.blue
            case .green: return UIColor.green
        }
    }
    
    static var colors:[Color] {
        return [.red, .blue, .green]
    }
    
    static func colorFromString(_ string:String) -> Color? {
        return Color(rawValue: string)
    }
}
