//
//  SettingsController.swift
//  SlowTime
//
//  Created by KKING on 2017/12/29.
//  Copyright © 2017年 KKING. All rights reserved.
//

import UIKit
import Moya
import PKHUD

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
            let alert = CQMAlert(title: "退出登录")
            let confirmAction = AlertOption(title: "退出", type: .normal, action: { [weak self] in
                self?.logOut()
            })
            let cancelAction = AlertOption(title: "取消", type: .cancel, action: nil)
            alert.addAlertOptions([cancelAction, confirmAction])
            alert.show()
            break
        default:()
            //            HexaHUD.show(with: "切换到\(dataArr["Title"]!)")
        }
    }
    
    
    private func logOut() {
        let provider = MoyaProvider<Request>()
        provider.rx.request(.logout)
            .asObservable()
            .mapJSON()
            .filterSuccessfulCode()
            .bind { (response) in

                let navigationController = R.storyboard.login().instantiateInitialViewController()! as? UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = navigationController
                
                UserDefaults.standard.set(nil, forKey: "accessToken_key")
                UserDefaults.standard.set(nil, forKey: "userHash_key")
                UserDefaults.standard.set(nil, forKey: "nickname_key")
                UserDefaults.standard.set(nil, forKey: "profile_key")
                UserDefaults.standard.set(false, forKey: "isLogin_key")
            }
            .disposed(by: disposeBag)
    }
}
