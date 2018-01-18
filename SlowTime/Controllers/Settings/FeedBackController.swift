//
//  FeedBackController.swift
//  SlowTime
//
//  Created by KKING on 2018/1/2.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

class FeedBackController: BaseViewController {
    
    @IBOutlet weak var toUserLabel: UILabel!
    
    @IBOutlet weak var formUserLabel: UILabel!
    
    @IBOutlet weak var createTimelbl: UILabel!
    
    @IBOutlet weak var mailContentTextView: UITextView!
    
    
    private var friend = Friend.create(with: NSDictionary(contentsOf: URL.CQMCacheURL!) as! [String : Any])

    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.title = "意见反馈"
        
        
        toUserLabel.text = (friend?.nickname)! + ":"
        formUserLabel.text = UserDefaults.standard.string(forKey: "nickname_key")
        createTimelbl.text = "2017年3月28日"

        navBar.wr_setRightButton(title: "发送", titleColor: .black)
        navBar.onClickRightButton = { [weak self] in
            self?.send()
        }
    
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        mailContentTextView.becomeFirstResponder()
    }
    
    
    fileprivate func send() {
        view.endEditing(true)
        let provider = MoyaProvider<Request>()
        provider.rx.request(.writeMail(toUser: (friend?.userHash)!, content: mailContentTextView.text))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .filterObject(to: Mail.self)
            .bind(onNext: { [weak self] (_) in
                self?.popAction()
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
