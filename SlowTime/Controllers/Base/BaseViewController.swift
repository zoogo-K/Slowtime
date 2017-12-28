//
//  LoginBaseViewController.swift
//  rota
//
//  Created by KKING on 2017/11/17.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isHidden = true
    }
    
    
    deinit{
        DLog("\(self) 💔💔💔")
    }
    
    @objc func popAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func disAction(){
        dismiss(animated: true, completion: nil)
    }
    
}

