//
//  ReadMailController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya
import PKHUD

class ReadMailController: BaseViewController {
    
    @IBOutlet weak var toUserName: UILabel!
    
    @IBOutlet weak var createTime: UILabel!
    
    @IBOutlet weak var fromUserName: UILabel!
    
    @IBOutlet weak var mailContent: UILabel!
    
    var emailType: Int = 1
    
    var mailId: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if emailType == 1 {
            navBar.wr_setRightButton(title: "写回信", titleColor: .black)
            navBar.onClickRightButton = { [weak self] in
                self?.performSegue(withIdentifier: R.segue.readMailController.showWrite, sender: nil)
            }
        }
        
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.getMail(mailId: mailId))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .filterObject(to: Mail.self)
            .subscribe { [weak self] (event) in
                if case .next(let mail) = event {
                    self?.toUserName.text = mail.toUser?.nickname
                    self?.fromUserName.text = mail.fromUser?.nickname
                    self?.mailContent.text = mail.content
                    self?.createTime.text = mail.createTime
                }else if case .error = event {
                    HUD.flash(.label("请求失败！"), delay: 1.0)
                }
            }
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
