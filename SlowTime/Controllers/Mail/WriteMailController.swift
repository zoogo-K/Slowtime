//
//  WriteMailController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya

class WriteMailController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navBar.wr_setRightButton(title: "装入信封", titleColor: .black)
        navBar.onClickLeftButton = { [weak self] in
            self?.saveMail()
        }
        navBar.onClickRightButton = { [weak self] in
            self?.saveMail(isPop: false)
        }
        
        
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
    }
    
    //离开此页则算保存邮件
    fileprivate func saveMail(isPop: Bool? = true) {
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.writeMail(toUser: "08c1d80272c14f8ba619e41e54285", content: "content"))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .filterObject(to: Mail.self)
            .subscribe { [weak self] (event) in
                if isPop! {
                    // 为何animated为true 就会pop两次
                    self?.navigationController?.popViewController(animated: false)
                }else {
                    self?.present(R.storyboard.mail().instantiateViewController(withIdentifier: "PackToSendController"), animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
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
