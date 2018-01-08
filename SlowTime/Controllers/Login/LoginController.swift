//
//  LoginController.swift
//  hexa
//
//  Created by KKING on 2017/2/15.
//  Copyright © 2017年 vincross. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import PKHUD

class LoginController: LoginBaseViewController {
    
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var getCodeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    private var timer: Timer?
    
    private var isCounting: Bool = false {
        willSet(newValue) {
            if newValue {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer(timer:)), userInfo: nil, repeats: true)
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    private var remainingSeconds: Int = 0 {
        willSet(newSeconds) {
            let seconds = newSeconds%60
            getCodeButton.setTitle("重新发送 \(seconds)s", for: .normal)
        }
    }
    
    @objc func updateTimer(timer: Timer) {// 更新时间
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }
        
        if remainingSeconds == 0 {
            getCodeButton.isSelected = false
            getCodeButton.setTitle("获取验证码", for: .normal)
            isCounting = !isCounting
            timer.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideOrShowBtn(btnType: .all, hide: true)
        
        
        _ = phoneTextField.rx.sentMessage(#selector(becomeFirstResponder))
        
        phoneTextField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespaces).localizedLowercase =~ Pattern.phone }
            .share(replay: 1)
            .bind { [unowned self] (valid) in
                DLog(valid)
                self.getCodeButton.isEnabled = valid
            }
            .disposed(by: disposeBag)
        
        
        
        getCodeButton.rx.tap
            .throttle(60, scheduler: MainScheduler.instance)
            .bind { [unowned self] in
                self.getCode()
            }
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind { [unowned self] in
                self.login()
            }
            .disposed(by: disposeBag)
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneTextField.text = "13120231088"
        codeTextField.text = "123456"
    }
    
    private func getCode() {
        self.remainingSeconds = 59
        self.isCounting = !self.isCounting
        
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.loginCode(phone: phoneTextField.text!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode({ (_, mess) in
                HUD.flash(.label(mess), delay: 1.0)
            })
            .bind(onNext: { (json) in
                DLog(json)
            })
            .disposed(by: disposeBag)
    }
    
    private func login() {
        
        //网络请求-验证码无误则跳转
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.login(phoneNumber: phoneTextField.text!, loginCode: codeTextField.text!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode({ (_, mess) in
                HUD.flash(.label(mess), delay: 1.0)
            })
            .filterObject(to: User.self)
            .subscribe { [weak self] (event) in
                if case .next(let user) = event {
                    if user.nickname != "" {
                        let navigationController = R.storyboard.mail().instantiateInitialViewController()! as? UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = navigationController
                    } else {
                        self?.performSegue(withIdentifier: R.segue.loginController.showInfo, sender: nil)
                    }
                    
                    UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                    UserDefaults.standard.set(user.userHash!, forKey: "userHash_key")
                    UserDefaults.standard.set(user.nickname!, forKey: "nickname_key")
                    UserDefaults.standard.set(user.profile!, forKey: "profile_key")
                    UserDefaults.standard.set(true, forKey: "isLogin_key")
                    
                }else if case .error = event {
                    HUD.flash(.label("请求失败！"), delay: 1.0)
                }
            }
            .disposed(by: disposeBag)
    }
}

