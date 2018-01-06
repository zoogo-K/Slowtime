//
//  SettingsController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/29.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit

class SettingsController: BaseViewController {

    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.tableFooterView = UIView()
        }
    }
    
    lazy var groupArr: [[String: String]] = {
        let arr = NSArray(contentsOfFile: Bundle.main.path(forResource: "settings", ofType: "plist")!)
        return arr! as! [[String : String]]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = "设置"
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isHidden = false
    }
    
}

// Mark: delagate,datasouce
extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArr.count
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "settings", for: indexPath)
        
        let dataArr = groupArr[indexPath.row]
        
        cell.textLabel?.font  = UIFont.my_systemFont(ofSize: 18)
        cell.textLabel?.text = dataArr["Title"]
        cell.accessoryType = dataArr["Desc"]! == "1" ? .disclosureIndicator : .none
        cell.detailTextLabel?.text = dataArr["Desc"]! == "2" ? Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String : ""
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataArr = groupArr[indexPath.row]
        switch dataArr["Target"]! {
        case "profile":
            performSegue(withIdentifier: R.segue.settingsController.showProfile, sender: nil)
            break
        case "feedback":
            performSegue(withIdentifier: R.segue.settingsController.showFeedback, sender: nil)
            break
        case "useragreement":
            performSegue(withIdentifier: R.segue.settingsController.showUserAgreement, sender: nil)
            break
        case "logout":
            
        
            break
        default:()
//            HexaHUD.show(with: "切换到\(dataArr["Title"]!)")
        }
    }
    
}
