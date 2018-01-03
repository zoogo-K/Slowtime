//
//  LoginBaseViewController.swift
//  rota
//
//  Created by KKING on 2017/12/29.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    lazy var navBar = WRCustomNavigationBar.CustomNavigationBar()

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        navigationController?.navigationBar.isHidden = true
        automaticallyAdjustsScrollViewInsets = false

        
        view.addSubview(navBar)
        
        // 设置自定义导航栏背景图片
        navBar.barBackgroundImage = UIImage(color: .white)
        
        // 设置自定义导航栏背景颜色
        navBar.backgroundColor = .white
        
        // 设置自定义导航栏标题颜色
        navBar.titleLabelColor = .black
        navBar.titleLabelFont = .my_systemFont(ofSize: 18)
        
        // 设置自定义导航栏左右按钮字体颜色
        navBar.wr_setTintColor(color: .black)
        
        if self.navigationController?.childViewControllers.count != 1 {
            navBar.wr_setLeftButton(image: RI.left()!)
        }
    }

    @objc fileprivate func back()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func popAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func disAction(){
        dismiss(animated: true, completion: nil)
    }
    
}

