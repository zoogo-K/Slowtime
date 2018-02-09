//
//  ViewController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/27.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import RxSwift
import SwiftyJSON

class UserListController: BaseViewController {
    
    @IBOutlet weak var dottBtn: UIButton!
    
    @IBOutlet weak var commendUserName: UILabel!
    @IBOutlet weak var commendUserInfo: UILabel!
    @IBOutlet weak var writeMailToCommendUser: UIButton!
    
    @IBOutlet weak var commendView: UIView!
    
    private var dottOpen: Bool = true
    
    @IBOutlet weak var viewbottomCon: NSLayoutConstraint!
    
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.backgroundColor = .clear
            tableview.bouncesZoom = false
            tableview.tableFooterView = UIView()
        }
    }
    
    private var editIndexPath: IndexPath = IndexPath(row: -1, section: 0)
    
    // 顶部刷新
    let header: MJRefreshNormalHeader = {
        $0.setTitle("下拉刷新", for: .idle)
        $0.setTitle("释放刷新", for: .pulling)
        $0.setTitle("加载信件", for: .refreshing)
        $0.stateLabel.font = .my_systemFont(ofSize: 15)
        $0.stateLabel.textColor = .white
        $0.activityIndicatorViewStyle = .white
        $0.lastUpdatedTimeLabel.isHidden = true
        $0.backgroundColor = .clear
        return $0
    }(MJRefreshNormalHeader())
    
    private var friends: [Friend]?
    
    private var shieldFriends: [Friend] = []
    
    private var commendFriend: Friend = Friend(json: JSON())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableview.mj_header = header
        
        navBar.barBackgroundImage = UIImage(color: .clear)
        navBar.backgroundColor = .clear
        navBar.wr_setBottomLineHidden(hidden: true)
        
        navBar.wr_setRightButton(image: RI.setting()!)
        navBar.onClickRightButton = { [weak self] in
            self?.performSegue(withIdentifier: R.segue.userListController.showSettings, sender: nil)
        }
        
        
        
        
        dottBtn.rx.tap
            .throttle(1, scheduler: MainScheduler.instance)
            .bind { [unowned self] in
                self.viewbottomCon.constant = self.dottOpen ? -187 : 0
                self.dottBtn.setImage(self.dottOpen ? RI.icon_arrow_up() : RI.icon_arrow_down(), for: .normal)
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { (b) in
                    self.dottOpen = !self.dottOpen
                })
            }
            .disposed(by: disposeBag)
        
        
        writeMailToCommendUser.rx.tap
            .bind { [unowned self] in
                self.performSegue(withIdentifier: R.segue.userListController.writeCommend, sender: nil)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarStyle = .lightContent
        request()
    }
    
    private func request() {
        
        let provider = MoyaProvider<Request>()
        provider.rx.requestWithLoading(.friends)
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .flatMap(to: Friend.self)
            .subscribe { [weak self] (event) in
                self?.tableview.mj_header.endRefreshing()
                if case .next(let friends) = event {
                    self?.friends = friends
                    DispatchQueue.main.async {
                        friends.forEach({ (friend) in
                            if friend.nickname == "从前慢" {
                                (friend.archived as NSDictionary).write(to: URL.CQMCacheURL!, atomically: true)
                            }
                        })
                        self?.tableview.reloadData()
                    }
                }else if case .error = event {
                    DLog("请求超时")
                }
            }
            .disposed(by: disposeBag)
        
        
        let providerRecommends = MoyaProvider<Request>()
        providerRecommends.rx.requestWithLoading(.recommends)
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .flatMap(to: Friend.self)
            .subscribe { [weak self] (event) in
                self?.tableview.mj_header.endRefreshing()
                if case .next(let friends) = event {
                    DispatchQueue.main.async {
                        self?.commendView.isHidden = false
                        self?.commendUserName.text = friends.first!.nickname
                        self?.commendUserInfo.text = friends.first!.profile
                        let title = friends.first?.sex == "男" ? "他" : "她"
                        self?.writeMailToCommendUser.setTitle("写封信给\(title)", for: .normal)
                        self?.commendFriend = friends.first!
                    }
                }else if case .error = event {
                    self?.commendView.isHidden = true
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    
    
    
    
    
    // 顶部刷新
    @objc func headerRefresh(){
        print("下拉刷新")
        // 结束刷新
        request()
    }
}

// Mark: delagate,datasouce
extension UserListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(friends?.count ?? 0, 9)
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "userList", for: indexPath) as! UserListCell
        cell.titleLbl.isHidden = indexPath.row < friends?.count ?? 0 ? false : true
        cell.youchuoImg.isHidden = indexPath.row < friends?.count ?? 0 ? false : true
        if indexPath.row < friends?.count ?? 0 {
            cell.friend = friends![indexPath.row]
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mailList = R.segue.userListController.showMailList(segue: segue) {
            let indexPath = sender as! IndexPath
            mailList.destination.friend = friends![indexPath.row]
        }else if let mailList = R.segue.userListController.writeCommend(segue: segue) {
            mailList.destination.friend = commendFriend
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < friends?.count ?? 0 {
            performSegue(withIdentifier: R.segue.userListController.showMailList, sender: indexPath)
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.row >= friends?.count ?? 0 {
            return []
        }
        
        let friend = friends![indexPath.row]
        
        let title = shieldFriends.contains(where: { $0.userHash == friend.userHash }) ? "取消屏蔽" : "屏蔽"
        
        let shieldAction = UITableViewRowAction(style: .normal, title: title) { [weak self] (action, indexpath) in
            HexaHUD.show(with: title == "屏蔽" ? "已屏蔽" : "已取消屏蔽")
            if title == "屏蔽" { self?.shieldFriends.append(friend) }
            else { self?.shieldFriends.remove(friend) }
            DispatchQueue.main.async {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
        let reportAction = UITableViewRowAction(style: .normal, title: "举报") { [weak self] (action, indexpath) in
            let feedback = R.storyboard.mail.feedBackController()
            feedback?.contentText = "我要举报\(friend.nickname ?? "")这个用户，因为"
            self?.navigationController?.pushViewController(feedback!, animated: true)
        }
        return [shieldAction, reportAction]
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if indexPath.row < friends?.count ?? 0 {
            editIndexPath = indexPath
            view.setNeedsLayout()
        }
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
                
                for index in 0 ..< subview.subviews.count {
                    if String(describing: subview.subviews[index]).range(of: actionStr) != nil {
                        if let button = subview.subviews[index] as? UIButton {
                            button.titleLabel?.font = .my_systemFont(ofSize: 15)
                            
                            if UIDevice.current.systemVersion >= "11" {
                                button.backgroundColor = index == 0 ? UIColor(hexString: "#F0F0F0") : UIColor(hexString: "#2E2E2E")
                                button.setTitleColor(index == 0 ? .black : .white, for: .normal)
                            }else{
                                button.backgroundColor = index != 0 ? UIColor(hexString: "#F0F0F0") : UIColor(hexString: "#2E2E2E")
                                button.setTitleColor(index != 0 ? .black : .white, for: .normal)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

