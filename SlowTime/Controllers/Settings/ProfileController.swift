//
//  ProfileController.swift
//  SlowTime
//
//  Created by KKING on 2018/1/2.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit

class ProfileController: BaseViewController {
    
    @IBOutlet weak var profileTextView: UITextView! {
        didSet {
            profileTextView.layer.borderColor = UIColor.black.cgColor
            profileTextView.layer.borderWidth = 1
            profileTextView.layer.masksToBounds = true
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.title = "修改资料"
        navBar.wr_setRightButton(title: "修改", titleColor: .black)
        navBar.onClickRightButton = { [weak self] in
            
        }
        
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    
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
