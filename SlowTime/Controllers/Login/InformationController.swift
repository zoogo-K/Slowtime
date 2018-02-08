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
    
    @IBOutlet weak var sexView: sexView!
    
    @IBOutlet weak var nickName: UITextField! {
        didSet {
            nickName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
            nickName.leftViewMode = .always
            
            nickName.layer.borderColor = UIColor.darkGray.cgColor
            nickName.layer.borderWidth = 1
            nickName.layer.masksToBounds = true
            nickName.delegate = self
        }
    }
    
    @IBOutlet weak var profileTextView: UITextView! {
        didSet {
            profileTextView.layer.borderColor = UIColor.darkGray.cgColor
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
        
        if (nickName.text?.count)! == 0{
            HexaHUD.show(with: "请检查输入内容！")
            return
        }
        
        
        
        if (nickName.text?.count)! > 12 {
            nickName.layer.borderColor = UIColor.red.cgColor
            HexaHUD.show(with: "昵称超限")
            return
        }
        
        if profileTextView.text.count > 50 {
            profileTextView.layer.borderColor = UIColor.red.cgColor
            HexaHUD.show(with: "个人介绍超限")
            return
        }
        

        let provider = MoyaProvider<Request>()
        provider.rx.request(.profile(nickName: nickName.text!, profile: profileTextView.text!, sex: sexView.sex))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode({ (_, mess) in
                HexaHUD.show(with: mess)
            })
            .mapObject(to: User.self)
            .subscribe { (event) in
                if case .next(let user) = event {
                    
                    UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                    UserDefaults.standard.set(user.sex!, forKey: "sex_key")
                    UserDefaults.standard.set(user.userHash!, forKey: "userHash_key")
                    UserDefaults.standard.set(user.nickname!, forKey: "nickname_key")
                    UserDefaults.standard.set(user.profile!, forKey: "profile_key")

                    let navigationController = R.storyboard.mail().instantiateInitialViewController()! as? UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = navigationController
                    
                }else if case .error = event {
                    HexaHUD.show(with: "请检查输入内容！")
                }
            }
            .disposed(by: disposeBag)
    }
}


extension InformationController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nickName.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        profileTextView.layer.borderColor = UIColor.darkGray.cgColor
    }
}


class sexView: UIView {
    
    var sex = "男"
    
    private func click(isManBtn: Bool) {
        
        if isManBtn {
            manBtn.backgroundColor = UIColor(hexString: "#C90000")
            womenBtn.backgroundColor = .white

            manBtn.layer.borderWidth = 0
            womenBtn.layer.borderWidth = 1
            
            manBtn.setTitleColor(.white, for: .normal)
            womenBtn.setTitleColor(.black, for: .normal)
            
            sex = "男"
        } else {
            manBtn.backgroundColor = .white
            womenBtn.backgroundColor = UIColor(hexString: "#C90000")
            
            manBtn.layer.borderWidth = 1
            womenBtn.layer.borderWidth = 0
            
            manBtn.setTitleColor(.black, for: .normal)
            womenBtn.setTitleColor(.white, for: .normal)
            
            sex = "女"
        }
    }
    
    @IBOutlet weak var manBtn: UIButton! {
        didSet {
            manBtn.backgroundColor = UIColor(hexString: "#C90000")
            
            manBtn.layer.borderColor = UIColor.darkGray.cgColor
            manBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var womenBtn: UIButton! {
        didSet {
            womenBtn.layer.borderWidth = 1
            womenBtn.layer.borderColor = UIColor.darkGray.cgColor
            womenBtn.layer.masksToBounds = true
        }
    }
    
    let disposeBag = DisposeBag()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        manBtn.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                self?.click(isManBtn: true)
            }
            .disposed(by: disposeBag)
        
        womenBtn.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind { [weak self] in
                self?.click(isManBtn: false)
            }
            .disposed(by: disposeBag)
    }
}

