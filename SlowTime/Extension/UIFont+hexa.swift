//
//  UIFont+hexa.swift
//  hexa
//
//  Created by KKING on 2017/2/24.
//  Copyright © 2017年 vincross. All rights reserved.
//

import UIKit

extension UIFont {
 
    open class func my_systemFont(ofSize fontSize: CGFloat) -> UIFont {
        if let font = RF.fZSXSLKJWGB10(size: fontSize) {
            return font
        }else {
            return .systemFont(ofSize: fontSize)
        }
    }
    
}
