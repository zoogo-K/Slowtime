//
//  MailListController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/28.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit

class MailListController: BaseViewController {
    
    @IBOutlet weak var tableview: UITableView!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "userList")
        
    }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
}

// Mark: delagate,datasouce
extension MailListController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20;
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "mailList", for: indexPath)

        cell.contentView.subviews.forEach { (view) in
            switch view.tag {
            case 2018:
                (view as! UILabel).text = "小波，你好啊！好久没有联系了。"
            case 2019:
                (view as! UILabel).text = "2018年1月1号 寄"
            default:
                view.isHidden = indexPath.row / 2 == 1 ? true : false
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

