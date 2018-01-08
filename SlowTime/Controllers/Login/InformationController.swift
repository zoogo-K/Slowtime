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
import PKHUD

class InformationController: LoginBaseViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var nickName: UITextField!
    
    @IBOutlet weak var profileTextView: UITextView! {
        didSet {
            profileTextView.layer.borderColor = UIColor.black.cgColor
            profileTextView.layer.borderWidth = 1
            profileTextView.layer.masksToBounds = true
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideOrShowBtn(btnType: .dis, hide: true)
        
        nextButton.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                self?.profileRequest()
            }
            .disposed(by: disposeBag)
        
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func profileRequest() {
        let provider = MoyaProvider<Request>()
        provider.rx.request(.profile(nickName: nickName.text!, profile: profileTextView.text!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode({ (_, mess) in
                HUD.flash(.label(mess), delay: 1.0)
            })
            .bind(onNext: { (json) in
                let navigationController = R.storyboard.mail().instantiateInitialViewController()! as? UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = navigationController
            })
            .disposed(by: disposeBag)
    }
    
}

