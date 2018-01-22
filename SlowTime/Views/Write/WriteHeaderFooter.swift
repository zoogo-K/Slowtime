//
//  WriteHeaderFooter.swift
//  SlowTime
//
//  Created by KKING on 2018/1/22.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit

class WriteHeader: UIView {

    @IBOutlet weak var toUserName: UILabel!
    
    var endBlock: (() -> ())?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endBlock!()
    }
    
}



class WriteFooter: UIView {
    
    @IBOutlet weak var fromUserName: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
}
