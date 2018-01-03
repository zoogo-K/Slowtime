//
//  RegisterInformationViewController.swift
//  hexa
//
//  Created by KKING on 2017/2/17.
//  Copyright © 2017年 vincross. All rights reserved.
//

import UIKit
import RxSwift
import Moya

class InformationController: LoginBaseViewController {
    
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideOrShowBtn(btnType: .dis, hide: true)
        
        
        nextButton.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind {
                let navigationController = R.storyboard.mail().instantiateInitialViewController()! as? UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = navigationController
            }
            .disposed(by: disposeBag)
        
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
    }
    
}

