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
            getCodeButton.setTitle("重新发送 \(seconds)s", for: .selected)
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
        
        
        getCodeButton.rx.tap
            .throttle(60, scheduler: MainScheduler.instance)
            .bind { [unowned self] in
                self.remainingSeconds = 59
                self.isCounting = !self.isCounting
                self.getCodeButton.isSelected = true
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
                _ = self.phoneTextField.resignFirstResponder()
                _ = self.codeTextField.resignFirstResponder()
            }
            .disposed(by: disposeBag)
    }
    
    func getCode(_ phone: String) {
        
    }
    
    func login() {
        
        //网络请求-验证码无误则跳转
        let provider = MoyaProvider<Request>()
        provider.rx.request(.login(phoneNumber: "13800138000", loginCode: "000000"))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .filterObject(to: User.self)
            .subscribe { [weak self] (event) in
                if case .next(let user) = event {
                    self?.performSegue(withIdentifier: R.segue.loginController.showInfo, sender: nil)
                    
                    UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                    UserDefaults.standard.set(true, forKey: "isLogin_key")

                }else if case .error = event {
                    DLog("失败")
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    
}

// Mark - TextFieldDelegate
extension LoginController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

