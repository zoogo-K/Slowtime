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

typealias AlertTextField = HexaGlobalAlert.TextFieldAction
typealias AlertOption = HexaGlobalAlert.ButtonAction

public class HexaGlobalAlert: UIView {
    
    var lineView: UIView = UIView()
    
    private var lineViewWidthCon: SnapKit.Constraint!
    
    public struct ButtonAction {
        public enum ActionType: Int {
            case normal, `continue`, cancel
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
    
    public struct TextFieldAction {
        let title: String
        let confirm: (AnimatedTextField) -> Void
    }
    
    private var lastView: UIView?
    
    let disposeBag = DisposeBag()
    
    var isMove = false

    
    init(title: String? = nil, image: UIImage? = nil, desc: String? = nil) {
        super.init(frame: .zero)
        
        alpha = 0;
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        //添加backView
        addSubview(backView)
        backView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(280)
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
                $0.top.equalTo(30)
                $0.left.equalTo(25)
                $0.right.equalTo(-25)
            }
        }
        
        backView.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            if title != nil{ // 有title 则scrollView距离title底部为15
                make.top.equalTo(titleLabel.snp.bottom).offset(15)
            }else{ // 无title则距离superView顶部30
                make.top.equalToSuperview().offset(30)
            }
            make.centerX.equalToSuperview()
            make.width.equalTo(245)
        }
        
        /// 有图片的情况
        if let image = image {
            
            let imgView: UIImageView = UIImageView(image: image)
            scrollView.addSubview(imgView)
            imgView.snp.makeConstraints({
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(image.size)
            })
            lastView = imgView
        }
        
        
        /// 有desc的情况
        if let desc = desc {
            
            scrollView.addSubview(descLabel)
            descLabel.attributedText = title != nil ? desc.attr.font(.my_systemFont(ofSize: 14)).lineSpace(7).textColor(.black).alignment(.center) : desc.attr.font(.my_systemFont(ofSize: 16)).lineSpace(7).textColor(.black).alignment(.center)
            //            descLabel.text = desc
            /*
             $0.font = .hexa_systemFont(ofSize: 14)
             $0.textColor = .black
             $0.numberOfLines = 0
             $0.textAlignment = .center
             */
            descLabel.snp.makeConstraints {
                if let lastView = lastView, lastView is UIImageView{
                    $0.top.equalTo(lastView.snp.bottom).offset(15)
                }else {
                    $0.top.equalToSuperview()
                }
                $0.leading.trailing.equalToSuperview()
                $0.width.equalTo(245)
            }
            lastView = descLabel
        }
    }
    
    func addAlertTextField(_ action: AlertTextField) {
        
        let aniTextField = AnimatedTextField()
        
        scrollView.addSubview(aniTextField)
        aniTextField.title = action.title
        aniTextField.font = .my_systemFont(ofSize: 14)
        aniTextField.titleColor = .black
        aniTextField.lineColor = .black//.withAlphaComponent(0.5)
        
        aniTextField.snp.makeConstraints({
            $0.left.equalToSuperview().offset(10)
            $0.right.equalToSuperview().offset(-10)
            $0.height.equalTo(42)
            guard let lastView = lastView else {
                $0.top.equalToSuperview().offset(20)
                return
            }
            if lastView is AnimatedTextField {
                $0.top.equalTo(lastView.snp.bottom).offset(8)
            }else{
                $0.top.equalTo(lastView.snp.bottom).offset(20)
            }
        })
        
        action.confirm(aniTextField)
        lastView = aniTextField
    }
    
    func addAlertOptions(_ options: [AlertOption], lineHeight: Float? = 1) {
        
        backView.addSubview(alertFootView)
        alertFootView.snp.makeConstraints({ (make) in
            make.top.equalTo(scrollView.snp.bottom).offset(scrollView.subviews.contains(where: { $0 is AnimatedTextField }) ? 40 : 20)
            make.left.right.bottom.equalToSuperview()
        })
        
        /// 两个以上action时
        if options.count > 2 {
            
            let newActions = options.sorted { $0.type.rawValue < $1.type.rawValue }
            
            for (i, a) in newActions.enumerated() {
                let line = getLine()
                let button = getButtonWith(actionType: a.type)
                alertFootView.addSubview(button)
                button.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview().offset(43*i)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(43)
                    if i == newActions.count - 1{
                        make.bottom.equalToSuperview()
                    }
                })
                button.rx.tap
                    .bind { [weak self] in
                        a.action?()
                        guard a.type != .`continue` else {
                            return
                        }
                        self?.hideAction()
                    }
                    .disposed(by: disposeBag)
                button.setTitle(a.title, for: .normal)
                
                
                alertFootView.addSubview(line)
                line.snp.makeConstraints({ (make) in
                    make.top.equalToSuperview().offset(40*i)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(lineHeight!)
                })
            }
            
        }else {//两个action时
            
            let line1 = getLine()
            let line2 = getLine()

            alertFootView.addSubview(line1)
            alertFootView.addSubview(line2)
            alertFootView.bringSubview(toFront: line1)
            alertFootView.bringSubview(toFront: line2)
            line2.isHidden = true
            
            line1.snp.makeConstraints { (make) in
                make.left.top.right.equalTo(alertFootView)
                make.height.equalTo(lineHeight!)
            }

            
            if lineHeight! > 1 {
                alertFootView.addSubview(lineView)
                lineView.snp.makeConstraints { (make) in
                    make.left.top.equalTo(alertFootView)
                    make.height.equalTo(lineHeight!)
                    lineViewWidthCon = make.width.equalTo(0).constraint
                }
                lineView.backgroundColor = .black
            }
            
            
            line2.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(alertFootView)
                make.width.equalTo(1)
                make.centerX.equalTo(alertFootView)
            }
            DispatchQueue.main.async {
                self.layoutWithTwoOrLessActions(options, lineH: line1, lineV: line2)
            }
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
    
    
    
    /// 两个或者一个action时
    ///
    /// - Parameters:
    ///   - actions: buttons
    ///   - lineH: 横分割线
    ///   - lineV: 竖分割线
    private func layoutWithTwoOrLessActions(_ options: [AlertOption], lineH: UIView, lineV: UIView
        ) {
        
        
        
        switch options.count {
        case 1:
            let button = getButtonWith(actionType: options[0].type)
            alertFootView.addSubview(button)
            button.snp.makeConstraints {
                $0.height.equalTo(44)
                $0.top.left.bottom.right.equalTo(alertFootView)
            }
            button.rx.tap
                .bind { [weak self] in
                    options[0].action?()
                    self?.hideAction()
                }
                .disposed(by: disposeBag)
            button.setTitle(options[0].title, for: .normal)
            
        case 2:
            lineV.isHidden = false
            
            let leftButton = getButtonWith(actionType: options[0].type)
            alertFootView.addSubview(leftButton)
            leftButton.snp.makeConstraints {
                $0.height.equalTo(50)
                $0.top.left.bottom.equalToSuperview()
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
                make.top.right.bottom.equalToSuperview()
                make.left.equalTo(leftButton.snp.right)
                make.width.height.equalTo(leftButton)
            })
            
            rightButton.rx.tap
                .bind { [weak self] in
                    options[1].action?()
                    guard options[1].type != .`continue` else {
                        return
                    }
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
            button.titleLabel?.font = .my_systemFont(ofSize: 15)
        case .normal:
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .my_systemFont(ofSize: 15)
            button.setTitleColor(UIColor(hexString: "#c4c4c4"), for: .disabled)
            confirmButton = button
        case .`continue`:
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .my_systemFont(ofSize: 15)
        }
        return button
    }
    
    
    
    
    /// 获取一根分割线
    ///
    /// - Returns: view
    private func getLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.5
        return view
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
        $0.layer.cornerRadius = 12
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
    
    private lazy var descLabel: UILabel = {
        $0.font = .my_systemFont(ofSize: 14)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    
    private lazy var scrollView: UIScrollView = {
        return $0
    }(UIScrollView())
    
    
    func show() {
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
            UIApplication.shared.keyWindow?.bringSubview(toFront: self)
            self.snp.makeConstraints({ (make) in
                make.top.left.right.bottom.equalToSuperview()
            })
            
            
            self.lastView?.snp.makeConstraints { $0.bottom.equalToSuperview() }
            self.scrollView.layoutIfNeeded()
            let height = self.scrollView.contentSize.height
            let maxHeight = Screen.width == 320 ? 264 : 336
            self.scrollView.snp.makeConstraints { $0.height.equalTo(min(height, CGFloat(maxHeight))) }
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
            }, completion: { (bll) in
                self.scrollView.subviews
                    .filter { $0 is AnimatedTextField }
                    .sorted(by: { $0.y < $1.y })
                    .first?.becomeFirstResponder()
            })
            
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func notifyUpdateProgress(progress: Double) {
        lineViewWidthCon.update(offset: Float(self.width) * Float(progress))
        self.alertFootView.layoutIfNeeded()
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
        NotificationCenter.default.removeObserver(self)
        DLog("deinit: \(self)💔💔💔")
    }
    
}
