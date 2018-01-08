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
    
    var friend: Friend?
   
    private var mails: [ListMail]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = friend?.nickname
      

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        request()
    }
    
    private func request() {
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.mailList(userhash: (friend?.userHash)!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .flatMap(to: ListMail.self)
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
    
}

// Mark: delagate,datasouce
extension MailListController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mails?.count ?? 0
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "mailList", for: indexPath) as! MailListCell
        cell.listMail = mails![indexPath.row]
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: R.segue.mailListController.showGetMail, sender: mails![indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let mail = sender as? ListMail else { return }
        
        if let mailList = R.segue.mailListController.showGetMail(segue: segue) {
            mailList.destination.mailId = mail.id!
            mailList.destination.emailType = mail.emailType!
            mailList.destination.navBar.title = navBar.title
            mailList.destination.friend = friend
        }
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = HexaGlobalAlert(title: "删除后将无法再恢复,少年要想好~")
            let confirmAction = AlertOption(title: "我想好了", type: .normal, action: { [weak self] in
                self?.disAction()
                //删除 并刷新。
            })
            let cancelAction = AlertOption(title: "我再想想", type: .cancel, action: nil)
            alert.addAlertOptions([confirmAction, cancelAction])
            alert.show()
        }
    }
    
}

