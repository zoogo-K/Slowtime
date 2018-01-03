//
//  MailListController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya

class MailListController: BaseViewController {
    
    @IBOutlet weak var tableview: UITableView!
   
    private var mails: [Mail]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let provider = MoyaProvider<Request>()
        provider.rx.request(.mailList(userhash: "08c1d80272c14f8ba619e41e54285"))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .flatMap(to: Mail.self)
            .subscribe { [weak self] (event) in
                if case .next(let mails) = event {
                    self?.mails = mails
                    DispatchQueue.main.async {
                        self?.tableview.reloadData()
                    }
                }else if case .error = event {
                    DLog("请求超时")
                }
            }
            .disposed(by: disposeBag)
    }  
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isHidden = false
//    }
    
}

// Mark: delagate,datasouce
extension MailListController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mails?.count ?? 0
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "mailList", for: indexPath)

        cell.contentView.subviews.forEach { (view) in
            switch view.tag {
            case 2018:
                (view as! UILabel).text = mails![indexPath.row].abstract
            case 2019:
                (view as! UILabel).text = mails![indexPath.row].createTime
            default:
                view.isHidden = mails![indexPath.row].isRead! ? true : false
            }
            
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        
    }
    
}

