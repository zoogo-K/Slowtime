//
//  FeedBackController.swift
//  SlowTime
//
//  Created by KKING on 2018/1/2.
//  Copyright © 2018年 KKING. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON
import PKHUD

class FeedBackController: BaseViewController {
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableHeaderView = header
            tableView.tableFooterView = footer
            tableView.backgroundColor = UIColor(patternImage: RI.mailbg()!)
        }
    }
    
    
    var cellHeight: CGFloat = 160
    
    private lazy var header: WriteHeader = {
        $0.toUserName.text = (friend?.nickname)! + ":"
        $0.endBlock = { [weak self] in
            self?.view.endEditing(true)
            let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextCell
            self?.cellHeight =  max(160, (cell!.contentTextView.text?.textHeight(with: .my_systemFont(ofSize: 17), width: Screen.width - 32))! + 20)
            self?.tableView.reloadData()
        }
        return $0
    }(Bundle.main.loadNibNamed("WriteHeaderFooter", owner: self, options: nil)![0] as! WriteHeader)
    
    private lazy var footer: WriteFooter = {
        $0.fromUserName.text = UserDefaults.standard.string(forKey: "nickname_key")
        $0.time.text = "2017年3月28日"
        return $0
    }(Bundle.main.loadNibNamed("WriteHeaderFooter", owner: self, options: nil)![1] as! WriteFooter)
    
    
    private var friend = Config.CqmUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "意见反馈"        
        
        navBar.wr_setRightButton(title: "发送", titleColor: .black)
        navBar.onClickRightButton = { [weak self] in
            self?.send()
        }
        
        
        view.rx.sentMessage(#selector(touchesBegan(_:with:)))
            .bind { [unowned self] (_) in
                _ = self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
                HUD.flash(.label("已发送"), delay: 1.0)
                self?.popAction()
            })
            .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Mark: delagate,datasouce
extension FeedBackController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}
