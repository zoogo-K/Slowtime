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

class LoginController: BaseViewController {
    
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    
    @IBOutlet weak var phoneTextField: UITextField! {
        didSet {
            phoneTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
            phoneTextField.leftViewMode = .always
            phoneTextField.layer.borderWidth = 1.0
            phoneTextField.layer.borderColor = UIColor.black.cgColor
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet weak var codeTextField: UITextField! {
        didSet {
            codeTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
            codeTextField.leftViewMode = .always
        }
    }
    
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
        
        navBar.barBackgroundImage = UIImage(color: .clear)
        navBar.backgroundColor = .clear
        navBar.wr_setBottomLineHidden(hidden: true)        
        
        
        phoneTextField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespaces).localizedLowercase =~ Pattern.phone }
            .share(replay: 1)
            .bind { [unowned self] (valid) in
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
        
        _ = phoneTextField.rx.sentMessage(#selector(becomeFirstResponder))
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
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
                HUD.flash(.label("验证码已发送"), delay: 1.0)
            })
            .disposed(by: disposeBag)
    }
    
    private func login() {
        
        //网络请求-验证码无误则跳转
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.login(phoneNumber: phoneTextField.text!, loginCode: codeTextField.text!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode({ (code, mess) in
                HUD.flash(.label(mess), delay: 1.0)
            })
            .mapObject(to: User.self)
            .subscribe { [weak self] (event) in
                if case .next(let user) = event {
                    if user.nickname != "" {
                        let navigationController = R.storyboard.mail().instantiateInitialViewController()! as? UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = navigationController
                        
                        UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                        UserDefaults.standard.set(user.userHash!, forKey: "userHash_key")
                        UserDefaults.standard.set(user.nickname!, forKey: "nickname_key")
                        UserDefaults.standard.set(user.profile!, forKey: "profile_key")
                    } else {
                        self?.performSegue(withIdentifier: R.segue.loginController.showInfo, sender: nil)
                    }
                    
                    UserDefaults.standard.set(true, forKey: "isLogin_key")
                    
                }
            }
            .disposed(by: disposeBag)
    }
}


extension LoginController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        phoneTextField.layer.borderColor = UIColor.black.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        phoneTextField.layer.borderColor = (phoneTextField.text?.trimmingCharacters(in: .whitespaces).localizedLowercase)! =~ Pattern.phone ? UIColor.black.cgColor : UIColor.red.cgColor
    }
}
