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
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableHeaderView = header
            tableView.tableFooterView = footer
            tableView.backgroundColor = UIColor(patternImage: RI.mailbg()!)
        }
    }
    
    var contentText: String = ""
    
    var cellHeight: CGFloat = 160
    
    private lazy var header: WriteHeader = {
        $0.toUserName.text = (friend?.nickname)! + ":"
        $0.endBlock = { [weak self] in
            self?.view.endEditing(true)
            let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell
            self?.cellHeight =  max(160, (cell!.contentTextView.text?.textHeight(with: .my_systemFont(ofSize: 17), width: Screen.width - 32))! + 20)
            self?.contentText = (cell?.contentTextView.text)!
            self?.tableView.reloadData()
        }
        return $0
    }(Bundle.main.loadNibNamed("WriteHeaderFooter", owner: self, options: nil)![0] as! WriteHeader)
    
    private lazy var footer: WriteFooter = {
        $0.fromUserName.text = UserDefaults.standard.string(forKey: "nickname_key")
        $0.time.text = "2017年3月28日"
        return $0
    }(Bundle.main.loadNibNamed("WriteHeaderFooter", owner: self, options: nil)![1] as! WriteFooter)
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "写给" + (friend?.nickname)!
        
        navBar.wr_setRightButton(title: friend == Config.CqmUser ? "发送" :" 装入信封", titleColor: .black)
        
        navBar.onClickRightButton = { [weak self] in
            self?.friend == Config.CqmUser ? self?.send() : self?.saveMail(isPop: false)
        }
        
        navBar.onClickLeftButton = { [weak self] in
            let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextCell
            if (cell.contentTextView.text.count) > 0 && self?.friend != Config.CqmUser {
                self?.saveMail(isPop: true)
            }else {
                self?.popAction()
            }
        }

        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell
        cell?.contentTextView.rx.text.orEmpty
            .asObservable()
            .bind { [weak self](text) in
                self?.navBar.wr_setLeftButton(title: text.count > 0 && self?.friend != Config.CqmUser ? "存草稿" : "返回", titleColor: .black)
            }
            .disposed(by: disposeBag)

        cell?.contentTextView.becomeFirstResponder()
        
        
        if ifEdit { //草稿
            let provider = MoyaProvider<Request>()
            provider.rx.requestWithLoading(.getMail(mailId: mailId))
                .asObservable()
                .mapJSON()
                .filterSuccessfulCode()
                .filterObject(to: Mail.self)
                .subscribe { [weak self] (event) in
                    if case .next(let mail) = event {
                        self?.contentText = mail.content!
                        self?.cellHeight =  max(160, (self?.contentText.textHeight(with: .my_systemFont(ofSize: 17), width: Screen.width - 32))! + 20)
                        self?.tableView.reloadData()
                    }else if case .error = event {
                        HUD.flash(.label("请求失败！"), delay: 1.0)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    
    
    fileprivate func send() {
        view.endEditing(true)
        let provider = MoyaProvider<Request>()
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextCell
        provider.rx.request(.writeMail(toUser: (friend?.userHash)!, content: (cell.contentTextView.text)!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .filterObject(to: Mail.self)
            .bind(onNext: { [weak self] (_) in
                HUD.flash(.label("已发送"), delay: 1.0)
                self?.popAction()
            })
            .disposed(by: disposeBag)
    }
    
    //离开此页则算保存邮件
    fileprivate func saveMail(isPop: Bool? = true) {
        view.endEditing(true)
        var target: Request
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell
        if ifEdit {
            target = .editMail(mailId: mailId, toUser: (friend?.userHash)!, content: (cell?.contentTextView.text)!)
        }else {
            target = .writeMail(toUser: (friend?.userHash)!, content: (cell?.contentTextView.text)!)
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
                }else if case .error = event {
                    HUD.flash(.label("请检查输入内容！"), delay: 1.0)
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
}


extension WriteMailController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextCell
        cell.contentTextView.text = contentText
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

