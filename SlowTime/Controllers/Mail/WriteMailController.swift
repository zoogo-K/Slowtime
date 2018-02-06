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

extension Notification.Name {
    static let endEdit = Notification.Name("endEdit")
}

class WriteMailController: BaseViewController {
    
    var friend: Friend?
    
    var ifEdit = false
    var mailId = ""
    var mail = Mail(json: JSON())
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = footer
            tableView.backgroundColor = UIColor(patternImage: RI.mailbg()!)
        }
    }
    
    
    var contentText: String = "\(UserDefaults.standard.string(forKey: "nickname_key")!):" + "\n      "
    
    var cellHeight: CGFloat = 190
    
    private lazy var footer: WriteFooter = {
        $0.fromUserName.text = UserDefaults.standard.string(forKey: "nickname_key")
        $0.time.text = getTimes()
        return $0
    }(Bundle.main.loadNibNamed("WriteHeaderFooter", owner: self, options: nil)![1] as! WriteFooter)
    
    func getTimes() -> String {
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var comps: DateComponents = DateComponents()
        comps = calendar.dateComponents([.year,.month,.day], from: Date())
        return "\(String(describing: comps.year!))年\(String(describing: comps.month!))月\(String(describing: comps.day!))号"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "写给" + (friend?.nickname)!
        
        navBar.wr_setRightButton(title: friend == Config.CqmUser ? "发送" :" 装入信封", titleColor: .black)
        
        navBar.onClickRightButton = { [weak self] in
            self?.friend == Config.CqmUser ? self?.send() : self?.saveMail(isPop: false)
        }
        
        navBar.wr_setLeftButton(title: " 存草稿", titleColor: .black)
        
        navBar.onClickLeftButton = { [weak self] in
            self?.reloadTableView()
            let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextCell
            if (cell.contentTextView.text.count) > 0 && self?.friend != Config.CqmUser {
                let alert = CQMAlert(title: "是否要保存草稿？")
                let confirmAction = AlertOption(title: "保存", type: .normal, action: { [weak self] in
                    self?.saveMail(isPop: true)
                })
                let cancelAction = AlertOption(title: "不用了", type: .cancel, action: {
                    self?.popAction()
                })
                alert.addAlertOptions([cancelAction, confirmAction])
                alert.show()
            }else {
                self?.popAction()
            }
        }
        
        
        NotificationCenter.default.addObserver(forName: .endEdit, object: nil, queue: .main) { [weak self] (_) in
            self?.reloadTableView()
        }
    }
    
    private func reloadTableView() {
        view.endEditing(true)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextCell
        cellHeight =  max(190, (cell.contentTextView.text?.textHeight(with: .my_systemFont(ofSize: 17), width: Screen.width - 32))!*1.5 + 20)
        contentText = (cell.contentTextView.text)!
        tableView.reloadData()
    }
    
    fileprivate func send() {
        view.endEditing(true)
        let provider = MoyaProvider<Request>()
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextCell
        provider.rx.request(.writeMail(toUser: (friend?.userHash)!, content: (cell.contentTextView.text)!))
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .mapObject(to: Mail.self)
            .bind(onNext: { [weak self] (_) in
                HexaHUD.show(with: "已发送")
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
            .mapObject(to: Mail.self)
            .subscribe { [weak self] (event) in
                if case .next(let mail) = event {
                    if isPop! {
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.mail = mail
                        self?.performSegue(withIdentifier: R.segue.writeMailController.showSend, sender: nil)
                    }
                }else if case .error = event {
                    HexaHUD.show(with: "请检查输入内容！")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension WriteMailController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextCell
        cell.contentTextView.attributedText = contentText.attr.font(.my_systemFont(ofSize: 17)).textColor(.black).lineSpace(7)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

