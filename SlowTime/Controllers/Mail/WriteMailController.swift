//
//  WriteMailController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit

class WriteMailController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        navigationBarButtonItem(with: .right, selector: #selector(packToSend), title: "装入信封")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func packToSend() {
        present(R.storyboard.mail().instantiateViewController(withIdentifier: "PackToSendController"), animated: true, completion: nil)
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
