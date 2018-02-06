//
//  AgreementController.swift
//  SlowTime
//
//  Created by KKING on 2018/1/2.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit

class AgreementController: BaseViewController {

    var ispresent = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "用户协议"
        
        
        if ispresent {
            navBar.wr_setLeftButton(title: "", titleColor: .black)
            navBar.wr_setRightButton(title: "关闭", titleColor: .black)
            navBar.onClickRightButton = { [weak self] in
                self?.disAction()
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
