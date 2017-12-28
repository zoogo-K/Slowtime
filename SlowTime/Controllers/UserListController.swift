//
//  ViewController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/27.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import MJRefresh

class UserListController: BaseViewController {
    
    @IBOutlet weak var tableview: UITableView!
    // 顶部刷新
    let header: MJRefreshNormalHeader = {
        $0.setTitle("下拉刷新", for: .idle)
        $0.setTitle("释放刷新", for: .pulling)
        $0.setTitle("加载信件", for: .refreshing)
        $0.lastUpdatedTimeLabel.isHidden = true
        $0.backgroundColor = .red
        return $0
    }(MJRefreshNormalHeader())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "userList")

        
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        self.tableview.mj_header = header
        


        

    }

    
    // 顶部刷新
    @objc func headerRefresh(){
        print("下拉刷新")
        // 结束刷新
        self.tableview.mj_header.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// Mark: delagate,datasouce
extension UserListController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "userList", for: indexPath)
        
        cell.textLabel!.text = "张三"
        cell.textLabel?.font = .my_systemFont(ofSize: 18)
        return cell
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mailList = R.segue.userListController.showMailList(segue: segue) {
            let indexPath = sender as! IndexPath
            mailList.destination.title = tableview.cellForRow(at: indexPath)?.textLabel?.text
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: R.segue.userListController.showMailList, sender: indexPath)
    }
}

