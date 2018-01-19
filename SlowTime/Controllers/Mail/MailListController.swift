//
//  MailListController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

class MailListController: BaseViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    var friend: Friend?
    
    private var editIndexPath: IndexPath = IndexPath(row: -1, section: 0)
    
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

                        if mails.contains(where: { $0.emailType == 1 }) {
                            
                            self?.navBar.wr_setRightButton(title: "写信", titleColor: .black)
                            self?.navBar.onClickRightButton = { [weak self] in
                                self?.performSegue(withIdentifier: R.segue.mailListController.showWrite, sender: nil)
                            }
                        }
                        
                        self?.tableview.reloadData()
                    }
                }else if case .error = event {
                    self?.mails = [ListMail]()
                    DispatchQueue.main.async {
                        self?.tableview.reloadData()
                    }
                    DLog("没有数据")
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
        if mails![indexPath.row].emailType == 3 && friend != Config.CqmUser {
            performSegue(withIdentifier: R.segue.mailListController.showdraft, sender: mails![indexPath.row])
        }else {
            performSegue(withIdentifier: R.segue.mailListController.showGetMail, sender: mails![indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let write = R.segue.mailListController.showWrite(segue: segue) {
            write.destination.friend = friend
            return
        }
        
        guard let mail = sender as? ListMail else { return }
        
        if let mailList = R.segue.mailListController.showGetMail(segue: segue) {
            mailList.destination.mailId = mail.id!
            mailList.destination.emailType = mail.emailType!
            mailList.destination.navBar.title = navBar.title
            mailList.destination.friend = friend
        }else if let editMail = R.segue.mailListController.showdraft(segue: segue) {
            editMail.destination.friend = friend
            editMail.destination.ifEdit = true
            editMail.destination.mailId = mail.id!
        }
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = CQMAlert(title: "删除后将无法再恢复,少年要想好~")
            let confirmAction = AlertOption(title: "我想好了", type: .normal, action: { [weak self] in
                self?.deleteMailRequest(mailId: (self?.mails![indexPath.row].id!)!)
                //删除 并刷新。
            })
            let cancelAction = AlertOption(title: "我再想想", type: .cancel, action: nil)
            alert.addAlertOptions([cancelAction, confirmAction])
            alert.show()
        }
    }
    
    private func deleteMailRequest(mailId: String) {
        let provider = MoyaProvider<Request>()
        provider.rx.request(.deleteMail(mailId: mailId))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .bind(onNext: { [weak self] (json) in
                self?.request()
            })
            .disposed(by: disposeBag)
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删"
    }
    
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        editIndexPath = indexPath
        view.setNeedsLayout()
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if editIndexPath.row < 0 { return }
        
        let cell = tableview.cellForRow(at: editIndexPath)
        let sup = UIDevice.current.systemVersion >= "11" ? tableview : cell!
        let swipeStr = UIDevice.current.systemVersion >= "11" ? "UISwipeActionPullView" : "UITableViewCellDeleteConfirmationView"
        let actionStr = UIDevice.current.systemVersion >= "11" ? "UISwipeActionStandardButton" : "_UITableViewCellActionButton"
        
        for subview in sup.subviews {
            if String(describing: subview).range(of: swipeStr) != nil {
                for sub in subview.subviews {
                    if String(describing: sub).range(of: actionStr) != nil {
                        if let button = sub as? UIButton {
                            button.titleLabel?.font = .my_systemFont(ofSize: 15)
                        }
                    }
                }
            }
        }
    }
}

