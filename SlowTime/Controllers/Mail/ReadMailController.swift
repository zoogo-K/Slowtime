//
//  ReadMailController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit

class ReadMailController: BaseViewController {
    
    var emailType: EmailType = .inBox
    
    
    enum EmailType {
        case inBox
        case outBox
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if emailType == .inBox {
            navigationBarButtonItem(with: .right, selector: #selector(showWrite), title: "写回信")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @objc func showWrite() {
        performSegue(withIdentifier: R.segue.readMailController.showWrite, sender: nil)
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
