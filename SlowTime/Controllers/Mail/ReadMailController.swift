//
//  ReadMailController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya

class ReadMailController: BaseViewController {
    
    var emailType: EmailType = .inBox
    
    var mailId: String = ""
    
    enum EmailType {
        case inBox
        case outBox
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if emailType == .inBox {
            navBar.wr_setRightButton(title: "写回信", titleColor: .black)
            navBar.onClickRightButton = { [weak self] in
                self?.performSegue(withIdentifier: R.segue.readMailController.showWrite, sender: nil)
            }
        }
        
//        let provider = MoyaProvider<Request>()
//        provider.rx.request(.mailList(userhash: "08c1d80272c14f8ba619e41e54285"))
//            .asObservable()
//            .mapJSON()
//            .filterSuccessfulCode()
//            .flatMap(to: Mail.self)
//            .subscribe { [weak self] (event) in
//                if case .next(let mails) = event {
//                    self?.mails = mails
//                    DispatchQueue.main.async {
//                        self?.tableview.reloadData()
//                    }
//                }else if case .error = event {
//                    DLog("请求超时")
//                }
//            }
//            .disposed(by: disposeBag)
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
