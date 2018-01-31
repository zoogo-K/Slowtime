//
//  ProfileController.swift
//  SlowTime
//
//  Created by KKING on 2018/1/2.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import PKHUD

class ProfileController: BaseViewController {
    
    @IBOutlet weak var nickName: UITextField! {
        didSet {
            nickName.text = UserDefaults.standard.string(forKey: "nickname_key")
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
            profileTextView.text = UserDefaults.standard.string(forKey: "profile_key")
            
            profileTextView.delegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "修改资料"
        navBar.wr_setRightButton(title: "修改", titleColor: .black)
        navBar.onClickRightButton = { [weak self] in
            self?.changeProfileRequest()
        }
        
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func changeProfileRequest() {
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
            .filterSuccessfulCode({ (code, mess) in
                HUD.flash(.label(mess), delay: 1.0)
            })
            .mapObject(to: User.self)
            .bind(onNext: { [weak self] (user) in
                if user.userHash != "" {
                    UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                    UserDefaults.standard.set(user.userHash!, forKey: "userHash_key")
                    UserDefaults.standard.set(user.nickname!, forKey: "nickname_key")
                    UserDefaults.standard.set(user.profile!, forKey: "profile_key")
                }
                self?.popAction()
            })
            .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension ProfileController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nickName.layer.borderColor = UIColor.black.cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        profileTextView.layer.borderColor = UIColor.black.cgColor
    }
}

