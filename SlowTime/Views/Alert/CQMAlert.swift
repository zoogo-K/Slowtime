//
//  HexaGlobalAlert.swift
//  hexa
//
//  Created by KKING on 2017/3/10.
//  Copyright © 2017年 vincross. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

typealias AlertOption = CQMAlert.ButtonAction

public class CQMAlert: UIView {
    
    public struct ButtonAction {
        public enum ActionType: Int {
            case normal, cancel
        }
        
        public static let cancelAlertOption = ButtonAction(title: "取消", type: .cancel)
        
        let title: String
        let type: ActionType
        var action: (() -> Void)?
        init(title: String, type: ActionType = .normal, action: (() -> Void)? = nil) {
            self.title = title
            self.type = type
            self.action = action
        }
    }
    
    let disposeBag = DisposeBag()
    
    init(title: String? = nil, desc: String? = nil) {
        super.init(frame: .zero)
        
        alpha = 0;
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        //添加backView
        addSubview(backView)
        backView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(270)
        }
        
        
        /// 有title的情况
        if let title = title {
            backView.addSubview(titleLabel)
            /*
             $0.font = .hexa_boldSystemFont(ofSize: 16)
             $0.textColor = .black
             $0.numberOfLines = 0
             $0.textAlignment = .center
             */
            titleLabel.attributedText = title.attr.font(.my_systemFont(ofSize: 16)).lineSpace(7).textColor(.black).alignment(.center)
            
            titleLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(20)
                $0.left.equalTo(62)
                $0.right.equalTo(-62)
            }
        }
    }
    
    func addAlertOptions(_ options: [AlertOption]) {
        
        backView.addSubview(alertFootView)
        alertFootView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(30)
            make.height.equalTo(56)
            make.left.right.bottom.equalToSuperview()
        })
        
        DispatchQueue.main.async {
            self.layoutWithTwoOrLessActions(options)
        }
        
    }
    
    private weak var confirmButton: UIButton?
    
    func bindToConfirmButtonEnabled(_ valid: Observable<Bool>?) {
        guard let confirmButton = confirmButton else { return }
        valid?
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    
    //直接设置confirmButton是否可用
    func setConfirmButtonEnabled(bool: Bool) {
        confirmButton?.isEnabled = bool
    }
    
    
    private func layoutWithTwoOrLessActions(_ options: [AlertOption]) {
        
        switch options.count {
        case 1:
            let leftButton = getButtonWith(actionType: options[0].type)
            alertFootView.addSubview(leftButton)
            leftButton.snp.makeConstraints {
                $0.width.equalTo(100)
                $0.height.equalTo(36)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-20)
            }
            leftButton.rx.tap
                .bind { [weak self] in
                    options[0].action?()
                    self?.hideAction()
                }
                .disposed(by: disposeBag)
            leftButton.setTitle(options[0].title, for: .normal)
            
        case 2:
            
            let leftButton = getButtonWith(actionType: options[0].type)
            alertFootView.addSubview(leftButton)
            leftButton.snp.makeConstraints {
                $0.width.equalTo(100)
                $0.height.equalTo(36)
                $0.left.equalToSuperview().offset(24)
                $0.bottom.equalToSuperview().offset(-20)
            }
            leftButton.rx.tap
                .bind { [weak self] in
                    options[0].action?()
                    self?.hideAction()
                }
                .disposed(by: disposeBag)
            leftButton.setTitle(options[0].title, for: .normal)
            
            let rightButton = getButtonWith(actionType: options[1].type)
            alertFootView.addSubview(rightButton)
            rightButton.snp.makeConstraints({ (make) in
                make.width.height.equalTo(leftButton)
                make.right.equalToSuperview().offset(-24)
                make.bottom.equalToSuperview().offset(-20)
            })
            
            rightButton.rx.tap
                .bind { [weak self] in
                    options[1].action?()
                    self?.hideAction()
                }
                .disposed(by: disposeBag)
            
            rightButton.setTitle(options[1].title, for: .normal)
            
        default: ()
        }
    }
    
    /// 创建不同类型的button
    ///
    /// - Parameter actionType: AlertOptionType
    /// - Returns: button
    private func getButtonWith(actionType: AlertOption.ActionType) -> UIButton {
        let button = UIButton()
        switch actionType{
        case .cancel:
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .my_systemFont(ofSize: 13)
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
            button.layer.masksToBounds = true
        case .normal:
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .my_systemFont(ofSize: 13)
            button.backgroundColor = UIColor(hexString: "#C90000")
            confirmButton = button
        }
        return button
    }
    
    
    private func hideAction() {
        removeFromSuperview()
    }
    
    
    private let alertFootView: UIView = {
        $0.backgroundColor = .clear
        return $0
    }(UIView())
    
    
    private let backView: UIView = {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
        return $0
    }(UIView())
    
    private lazy var titleLabel: UILabel = {
        $0.font = .my_systemFont(ofSize: 16)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    func show() {
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
            UIApplication.shared.keyWindow?.bringSubview(toFront: self)
            self.snp.makeConstraints({ (make) in
                make.top.left.right.bottom.equalToSuperview()
            })
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
            })
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if backView.frame.contains(point) {
            return view
        }else {
            return self
        }
    }
    
    deinit {
        DLog("deinit: \(self)💔💔💔")
    }
    
}
