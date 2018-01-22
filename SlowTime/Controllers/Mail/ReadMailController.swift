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
import Kingfisher

class ReadMailController: BaseViewController {
    
    var friend: Friend?
    
    @IBOutlet weak var envelopeBottomTearViewStamp: UIImageView!
    
    @IBOutlet weak var envelopeBottomTearViewToUserZip: UILabel!
    @IBOutlet weak var envelopeBottomTearViewTouserlbl: UILabel!
    
    @IBOutlet weak var envelopeBottomTearViewfromuserlbl: UILabel!
    @IBOutlet weak var envelopeBottomTearViewFromUserZip: UILabel!
    
    
    @IBOutlet weak var envelopeBottomTearView: UIView!
    
    @IBOutlet weak var mailView: UIView!
    
    @IBOutlet weak var yinzhangImg: UIImageView! {
        didSet {
            yinzhangImg.isHidden = true
        }
    }
    
    @IBOutlet weak var toUserName: UILabel!
    
    @IBOutlet weak var createTime: UILabel!
    
    @IBOutlet weak var fromUserName: UILabel!
    
    @IBOutlet weak var mailContent: UILabel!
    
    @IBOutlet weak var mailScrollView: UIScrollView! {
        didSet {
            mailScrollView.backgroundColor = UIColor(patternImage: RI.mailbg()!)
        }
    }
    
    
    var emailType: Int = 1
    
    var mailId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.getMail(mailId: mailId))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .filterObject(to: Mail.self)
            .subscribe { [weak self] (event) in
                if case .next(let mail) = event {
                    self?.toUserName.text = (mail.toUser?.nickname)! + ":"
                    self?.fromUserName.text = mail.fromUser?.nickname
                    self?.mailContent.text = mail.content
                    self?.createTime.text = mail.updateTime?.StringFormartTime()
                    
                    self?.envelopeBottomTearViewToUserZip.text = mail.toUser?.zipCode?.StringToZipCode()
                    self?.envelopeBottomTearViewTouserlbl.text = (mail.toUser?.nickname)! + " 收"
                    self?.envelopeBottomTearViewfromuserlbl.text = (mail.fromUser?.nickname)! + " 寄"
                    self?.envelopeBottomTearViewFromUserZip.text = mail.fromUser?.zipCode

                    self?.envelopeBottomTearViewStamp.kf.setImage(with: ImageResource(downloadURL: URL(string: mail.stampIcon ?? "") ?? URL(string: "")!), placeholder: RI.add_stamp())

                }else if case .error = event {
                    HUD.flash(.label("请求失败！"), delay: 1.0)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        envelopeBottomTearView.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        
        if emailType == 1 {
            navBar.wr_setRightButton(title: "写回信", titleColor: .black)
            navBar.onClickRightButton = { [weak self] in
                self?.performSegue(withIdentifier: R.segue.readMailController.showWrite, sender: nil)
            }
        }
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 左下角印章的iphoneX适配
        yinzhangImg.y = max(yinzhangImg.y, Screen.height - yinzhangImg.height - 16 -  (WRCustomNavigationBar.isIphoneX ? (44 + 34) : 20))
        yinzhangImg.isHidden = false
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mailList = R.segue.readMailController.showWrite(segue: segue) {
            mailList.destination.friend = friend
        }
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
