//
//  LoginBaseViewController.swift
//  rota
//
//  Created by KKING on 2017/12/29.
//

import UIKit
import RxSwift

class LoginBaseViewController: UIViewController {
    
    enum ItemButtonType: Int {
        case all
        case pop
        case dis
    }
    
    private var popButton: UIButton = {
        $0.setImage(RI.left(), for: .normal)
        $0.addTarget(self, action: #selector(popAction), for: .touchUpInside)
        $0.sizeToFit()
        return $0
    }(UIButton())
    
    private var disButton: UIButton = {
        $0.setImage(RI.cha(), for: .normal)
        $0.addTarget(self, action: #selector(disAction), for: .touchUpInside)
        $0.sizeToFit()
        return $0
    }(UIButton())
    
    public func hideOrShowBtn(btnType: ItemButtonType, hide: Bool) {
        switch btnType {
        case .all:
            popButton.isHidden = hide
            disButton.isHidden = hide
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !hide
            break
        case .pop:
            popButton.isHidden = hide
            break
        case .dis:
            disButton.isHidden = hide
            break
        }
    }
    
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge()
        
        
        view.addSubview(disButton)
        disButton.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.top.equalTo(32)
            make.width.height.equalTo(30)
        }
        
        
        view.addSubview(popButton)
        popButton.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(32)
            make.width.height.equalTo(30)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
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
