//
//  HexaAlert.swift
//  hexa
//
//  Created by 郭源 on 2016/10/11.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit

final class HexaAlert {
    
    static func confirmOrCancel(title: String,
        message: String? = nil,
        confirmTitle: String? = nil,
        cancelTitle: String = "取消",
        in viewController: UIViewController? = nil,
        confirmAction: (() -> Void)? = nil,
        cancelAction: (() -> Void)? = nil) {
        let alert = HexaGlobalAlert(title: title, desc: message)
        if let confirmTitle = confirmTitle {
            let cancelAction = AlertOption(title: cancelTitle, type: .cancel, action: { 
                cancelAction?()
            })
            let confirmAction = AlertOption(title: confirmTitle, type: .normal, action: { 
                confirmAction?()
            })
            alert.addAlertOptions([cancelAction, confirmAction])
        }else {
            let confirmAction = AlertOption(title: cancelTitle, type: .normal, action: { 
                cancelAction?()
            })
            alert.addAlertOptions([confirmAction])
        }
        alert.show()
    }
}
