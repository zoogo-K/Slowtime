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

class UserListController: BaseViewController {
    
    @IBOutlet weak var dottBtn: UIButton!
    
    private var dottOpen: Bool = false
    
    @IBOutlet weak var viewbottomCon: NSLayoutConstraint!
    
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.backgroundColor = .clear
            tableview.tableFooterView = UIView()
        }
    }
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
                        self?.tableview.reloadData()
                    }
                }else if case .error = event {
                    DLog("请求超时")
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
        let cell = tableview.dequeueReusableCell(withIdentifier: "userList", for: indexPath)
        if indexPath.row < friends?.count ?? 0 {
            cell.textLabel!.text = friends![indexPath.row].nickname
            cell.textLabel?.font = .my_systemFont(ofSize: 18)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mailList = R.segue.userListController.showMailList(segue: segue) {
            let indexPath = sender as! IndexPath
            mailList.destination.navBar.title = tableview.cellForRow(at: indexPath)?.textLabel?.text
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < friends?.count ?? 0 {

        }
        performSegue(withIdentifier: R.segue.userListController.showMailList, sender: indexPath)
    }
}

