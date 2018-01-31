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

class InformationController: BaseViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var nickName: UITextField! {
        didSet {
            nickName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
            nickName.leftViewMode = .always
            
            nickName.layer.borderColor = UIColor.black.cgColor
            nickName.layer.borderWidth = 1
            nickName.layer.masksToBounds = true
            nickName.delegate = self
        }
    }
    
    @IBOutlet weak var profileTextView: UITextView! {
        didSet {
            profileTextView.layer.borderColor = UIColor.black.cgColor
            profileTextView.layer.borderWidth = 1
            profileTextView.layer.masksToBounds = true
            
            profileTextView.delegate = self
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navBar.title = "完善信息"
        
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
        view.endEditing(true)
        
        if (nickName.text?.count)! == 0 || profileTextView.text.count == 0{
            HUD.flash(.label("请检查输入内容！"), delay: 1.0)
            return
        }
        
        
        
        if (nickName.text?.count)! > 12 {
            nickName.layer.borderColor = UIColor.red.cgColor
            HUD.flash(.label("昵称超限"), delay: 1)
            return
        }
        
        if profileTextView.text.count > 50 {
            profileTextView.layer.borderColor = UIColor.red.cgColor
            HUD.flash(.label("个人介绍超限"), delay: 1)
            return
        }
        

        let provider = MoyaProvider<Request>()
        provider.rx.request(.profile(nickName: nickName.text!, profile: profileTextView.text!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode({ (_, mess) in
                HUD.flash(.label(mess), delay: 1.0)
            })
            .mapObject(to: User.self)
            .subscribe { (event) in
                if case .next(let user) = event {
                    
                    UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                    UserDefaults.standard.set(user.userHash!, forKey: "userHash_key")
                    UserDefaults.standard.set(user.nickname!, forKey: "nickname_key")
                    UserDefaults.standard.set(user.profile!, forKey: "profile_key")

                    let navigationController = R.storyboard.mail().instantiateInitialViewController()! as? UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = navigationController
                    
                }else if case .error = event {
                    HUD.flash(.label("请检查输入内容！"), delay: 1.0)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}


extension InformationController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nickName.layer.borderColor = UIColor.black.cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        profileTextView.layer.borderColor = UIColor.black.cgColor
    }
}

