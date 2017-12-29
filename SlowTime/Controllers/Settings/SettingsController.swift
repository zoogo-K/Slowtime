//
//  SettingsController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/29.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit

class SettingsController: BaseViewController {

    @IBOutlet weak var tableview: UITableView!
    
    lazy var groupArr: [[String: Any]] = {
        let arr = NSArray(contentsOfFile: Bundle.main.path(forResource: "settings", ofType: "plist")!)
        return arr! as! [[String : Any]]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
}

// Mark: delagate,datasouce
extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArr.count
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "settings", for: indexPath)
        
        let dataArr = groupArr[indexPath.row]
        
        guard let text = dataArr["Title"] as? String else{
            return UITableViewCell()
        }
        cell.textLabel?.font  = UIFont.my_systemFont(ofSize: 15)
        cell.textLabel?.text = text
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
