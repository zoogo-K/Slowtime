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
    
    @IBOutlet weak var nickNameVerifylbl: UILabel!
    @IBOutlet weak var textViewVerifylbl: UILabel!

    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var nickName: UITextField! {
        didSet {
            nickName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
            nickName.leftViewMode = .always
        }
    }
    
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
        
        nickName.rx.text.orEmpty.asObservable().bind { [weak self] in
            self?.nickNameVerifylbl.text = String(describing: $0.count) + " / 5"
            }
            .disposed(by: disposeBag)
        
        profileTextView.rx.text.orEmpty.asObservable().bind { [weak self] in
            self?.textViewVerifylbl.text = String(describing: $0.count) + " / 50"
            }
            .disposed(by: disposeBag)
        
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
            .filterObject(to: User.self)
            .subscribe { (event) in
                if case .next(let user) = event {
                    
                    UserDefaults.standard.set(user.accessToken!, forKey: "accessToken_key")
                    UserDefaults.standard.set(user.userHash!, forKey: "userHash_key")
                    UserDefaults.standard.set(user.nickname!, forKey: "nickname_key")
                    UserDefaults.standard.set(user.profile!, forKey: "profile_key")

                    let navigationController = R.storyboard.mail().instantiateInitialViewController()! as? UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = navigationController
                    
                }else if case .error = event {
                    HUD.flash(.label("请求失败！"), delay: 1.0)
                }
            }
            .disposed(by: disposeBag)
    }
    
}

