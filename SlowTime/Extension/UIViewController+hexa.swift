//
//  UIViewController+hexa.swift
//  hexa
//
//  Created by KKING on 2017/2/23.
//  Copyright © 2017年 vincross. All rights reserved.
//

import UIKit

extension UIViewController {
    
    enum BarButtonItemLocation {
        case left, right
    }
    
    func navigationBarButtonItem(with direction: BarButtonItemLocation, selector: Selector, title: String? = nil, textColor: UIColor = UIColor.hexaCustomMainText, image: UIImage? = nil) -> Void {
        
        let button = UIButton(type: .custom)
        button.addTarget(self, action: selector, for: .touchUpInside)
        if let image = image {
            button.setImage(image, for: .normal)
            button.frame = CGRect(origin: .zero, size: image.size)
        }else if let title = title {
            button.setTitle(title, for: .normal)
            let size = title.stringRect(with: .systemFont(ofSize: 17))
            button.frame = CGRect(x: 0, y: 0, width: size.width+8, height: 30)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17)
        }
        let item = UIBarButtonItem(customView: button)
        if direction == .left {
            navigationItem.leftBarButtonItem = item
        }else {
            navigationItem.rightBarButtonItem = item
        }
    }
    
}
