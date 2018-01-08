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
    
    var friend: Friend?
    
    @IBOutlet weak var toUserLabel: UILabel!
    
    @IBOutlet weak var formUserLabel: UILabel!
    
    @IBOutlet weak var createTimelbl: UILabel!
    
    @IBOutlet weak var mailContentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "写给" + (friend?.nickname)!
        
        toUserLabel.text = friend?.nickname
        formUserLabel.text = UserDefaults.standard.string(forKey: "nickname_key")
        createTimelbl.text = "测试时间"
        
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
        provider.rx.requestWithLoading(.writeMail(toUser: (friend?.userHash)!, content: mailContentTextView.text))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .filterObject(to: Mail.self)
            .subscribe { [weak self] (event) in
                if isPop! {
                    // 为何animated为true 就会pop两次
//                    self?.wr_toLastViewController(animated: true)
                    self?.navigationController?.popViewController(animated: false)
                }else {
                   
                    let packToSend = R.storyboard.mail().instantiateViewController(withIdentifier: "PackToSendController") as! PackToSendController
                    packToSend.image = (self?.screenshot())!
                    self?.present(packToSend, animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)
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
