//
//  WriteMailController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya
import PKHUD
import SwiftyJSON

class WriteMailController: BaseViewController {
    
    var friend: Friend?
    
    var ifEdit = false
    var mailId = ""
    var mail = Mail(json: JSON())
    
    @IBOutlet weak var toUserLabel: UILabel!
    
    @IBOutlet weak var formUserLabel: UILabel!
    
    @IBOutlet weak var createTimelbl: UILabel!
    
    @IBOutlet weak var mailContentTextView: UITextView!
    
    @IBOutlet weak var mailContentTextViewHeightCon: NSLayoutConstraint!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "写给" + (friend?.nickname)!
        
        toUserLabel.text = (friend?.nickname)! + ":"
        formUserLabel.text = UserDefaults.standard.string(forKey: "nickname_key")
        createTimelbl.text = "2017年3月28日"
        
        navBar.wr_setRightButton(title: friend == Config.CqmUser ? "发送" :" 装入信封", titleColor: .black)
        
        navBar.onClickRightButton = { [weak self] in
            self?.saveMail(isPop: false)
        }
        
        navBar.onClickLeftButton = { [weak self] in
            if (self?.mailContentTextView.text.count)! > 0 && self?.friend != Config.CqmUser {
                self?.saveMail(isPop: true)
            }else {
                self?.popAction()
            }
        }

        
        mailContentTextView.rx.text.orEmpty
            .asObservable()
            .bind { [weak self](text) in
                self?.navBar.wr_setLeftButton(title: text.count > 0 ? "存草稿" : "返回", titleColor: .black)
            }
            .disposed(by: disposeBag)
        
        
        mailContentTextView.rx.text.orEmpty
            .asObservable()
            .bind { [weak self](text) in
                if text.count < 10 { return }
                self?.mailContentTextViewHeightCon.constant = text.stringRect(with: .my_systemFont(ofSize: 17)).height + 20
            }
            .disposed(by: disposeBag)
        
        
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        mailContentTextView.becomeFirstResponder()
        
        if ifEdit {
            let provider = MoyaProvider<Request>()
            provider.rx.requestWithLoading(.getMail(mailId: mailId))
                .asObservable()
                .mapJSON()
                .filterSuccessfulCode()
                .filterObject(to: Mail.self)
                .subscribe { [weak self] (event) in
                    if case .next(let mail) = event {
                        self?.mailContentTextView.text = mail.content
                    }else if case .error = event {
                        HUD.flash(.label("请求失败！"), delay: 1.0)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    //离开此页则算保存邮件
    fileprivate func saveMail(isPop: Bool? = true) {
        view.endEditing(true)
        var target: Request
        if ifEdit {
            target = .editMail(mailId: mailId, toUser: (friend?.userHash)!, content: mailContentTextView.text)
        }else {
            target = .writeMail(toUser: (friend?.userHash)!, content: mailContentTextView.text)
        }
        let provider = MoyaProvider<Request>()
        provider.rx.request(target)
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .filterObject(to: Mail.self)
            .subscribe { [weak self] (event) in
                if case .next(let mail) = event {
                    if isPop! {
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.mail = mail
                        self?.performSegue(withIdentifier: R.segue.writeMailController.showSend, sender: nil)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let send = R.segue.writeMailController.showSend(segue: segue) {
            send.destination.mail = mail
            return
        }
    }
    
    
    
    private func screenshot() -> UIImage {
        UIGraphicsBeginImageContext(view.size)
        let ctx = UIGraphicsGetCurrentContext();
        view.layer.render(in: ctx!)
        //获取图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage!
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
