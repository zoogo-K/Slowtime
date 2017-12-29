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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideOrShowBtn(btnType: .all, hide: true)
        
//        phoneTextField.rx.text.orEmpty
//            .map { $0.trimmingCharacters(in: .whitespaces).localizedLowercase =~ Pattern.phone }
//            .share(replay: 1)
//            .bind { [unowned self] (valid) in
//                self.loginButton.isEnabled = valid
//            }
//            .disposed(by: disposeBag)
        
        _ = phoneTextField.rx.sentMessage(#selector(becomeFirstResponder))
        
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
        performSegue(withIdentifier: R.segue.loginController.showInfo, sender: nil)
    }
    
}

// Mark - TextFieldDelegate
extension LoginController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
}

