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
    
    @IBOutlet weak var settingSexView: settingSexView! {
        didSet {
            settingSexView.localSex = UserDefaults.standard.string(forKey: "sex_key")!
        }
    }
    
    @IBOutlet weak var nickName: UITextField! {
        didSet {
            nickName.text = UserDefaults.standard.string(forKey: "nickname_key")
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
            profileTextView.text = UserDefaults.standard.string(forKey: "profile_key")
            
            profileTextView.delegate = self
        }
    }
    
    
    private var changeBtnCanUse: Bool = false {
        didSet {
            navBar.wr_setRightButton(title: "修改", titleColor: changeBtnCanUse ? .black : .lightGray)
            navBar.onClickRightButton = { [weak self] in
                self?.changeProfileRequest(changeBtnCanUse: (self?.changeBtnCanUse)!)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "修改资料"
        
        
        let nameValid = nickName.rx.text.orEmpty
            .map {
                return $0 != UserDefaults.standard.string(forKey: "nickname_key")
            }
            .share(replay: 1)
        
        let profileValid = profileTextView.rx.text.orEmpty
            .map {
                return $0 != UserDefaults.standard.string(forKey: "profile_key")
            }
            .share(replay: 1)
        
        
        Observable
            .combineLatest(nameValid, profileValid) {
                $0 || $1
            }
            .bind(onNext: { [weak self](b) in
                self?.changeBtnCanUse = b
            })
            .disposed(by: disposeBag)
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func changeProfileRequest(changeBtnCanUse: Bool) {
        if !changeBtnCanUse { return }
        view.endEditing(true)
        
        if (nickName.text?.count)! == 0 || profileTextView.text.count == 0{
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
        provider.rx.request(.profile(nickName: nickName.text!, profile: profileTextView.text!, sex: settingSexView.sex))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode({ (code, mess) in
                HexaHUD.show(with: mess)
            })
            .mapObject(to: User.self)
            .bind(onNext: { [weak self] (user) in
                if user.userHash != "" {
                    UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                    UserDefaults.standard.set(user.sex!, forKey: "sex_key")
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
        nickName.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        profileTextView.layer.borderColor = UIColor.darkGray.cgColor
    }
}



class settingSexView: UIView {
    
    var sex = "男"
    
    var localSex: String?
    
    
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
        
        switch localSex {
        case "男"?:
            click(isManBtn: true)
        case "女"?:
            click(isManBtn: false)
        default: break
        }
        
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


