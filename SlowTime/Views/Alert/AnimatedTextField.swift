//
//  AnimatedTextField.swift
//  hexa
//
//  Created by 郭源 on 2017/2/14.
//  Copyright © 2017年 vincross. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: AnimatedTextField {
    var isNotError: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { control, value in
            control.isError = !value
        }
    }
}

@IBDesignable
final class AnimatedTextField: UITextField {

    var titleFadeInDuration: TimeInterval = 0.15
    var titleFadeOutDuration: TimeInterval = 0.15
    
    override var placeholder: String? {
        didSet {
            setNeedsDisplay()
            updateAttributedPlaceholder()
            updateTitleLabel()
        }
    }
    
    override var font: UIFont? {
        didSet {
            titleFont = font ?? .my_systemFont(ofSize: 15)
        }
    }
    
    @IBInspectable var placeholderColor: UIColor = .lightGray {
        didSet {
            updateAttributedPlaceholder()
        }
    }
    
    @IBInspectable var placeholderFont: UIFont? {
        didSet {
            updateAttributedPlaceholder()
        }
    }
    
    fileprivate let titleLabel = UILabel()
    fileprivate let lineView = UIView()
    
    @IBInspectable var title: String? {
        didSet {
            updateTitleLabel()
        }
    }
    
    @IBInspectable var selectedTitle: String? {
        didSet {
            updateTitleLabel()
        }
    }
    
    @IBInspectable var titleFont: UIFont = .my_systemFont(ofSize: 15) {
        didSet {
            titleLabel.font = titleFont
        }
    }
    
    @IBInspectable var titleColor: UIColor = .hexaCustomDetailText {
        didSet {
            updateLineAndTitleColor()
        }
    }
    
    @IBInspectable var selectedTitleColor: UIColor = .hexaCustomDetailText {
        didSet {
            updateLineAndTitleColor()
        }
    }
    
    @IBInspectable var lineColor: UIColor = .black {
        didSet {
            updateLineAndTitleColor()
        }
    }
    
    @IBInspectable var selectedLineColor: UIColor = .black {
        didSet {
            updateLineAndTitleColor()
        }
    }
    
    @IBInspectable var isError: Bool = false {
        didSet {
            updateControl(animated: true)
        }
    }
    
    @IBInspectable var errorMessage: String?
    
    @IBInspectable var errorColor: UIColor = .hexaErrorText {
        didSet {
            updateLineAndTitleColor()
        }
    }
    
    @IBInspectable var lineHeight: CGFloat = 1.0
    
    @IBInspectable var selectedLineHeight: CGFloat = 1.0
    
    override var text: String? {
        didSet {
            updateControl(animated: false)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateLineView()
            updateLineAndTitleColor()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateControl(animated: true)
        }
    }
    
    override var isSecureTextEntry: Bool {
        didSet {
            fixCaretPosition()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        updateControl(animated: true)
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        updateControl(animated: true)
        return super.resignFirstResponder()
    }
    
    fileprivate var _titleVisible = false
    fileprivate var _renderingInInterfaceBuilder = false
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithSubviews()
    }
    
    private func initWithSubviews() {
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = titleFont
        titleLabel.textColor = titleColor
        let rect = placeholderRect(forBounds: bounds)
        titleLabel.frame = CGRect(x: 0, y: rect.origin.y, width: bounds.width, height: rect.size.height)
        addSubview(titleLabel)
        
        lineView.isUserInteractionEnabled = false
        addSubview(lineView)
        lineView.backgroundColor = lineColor
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(lineHeight)
        }
        
        rx.controlEvent(.editingChanged)
            .bind { [unowned self] in
                self.updateControl(animated: true)
            }
            .disposed(by: disposeBag)
    }

}

fileprivate extension AnimatedTextField {
    
    fileprivate var editingOrSelected: Bool {
        return super.isEditing || isSelected
    }
    
    fileprivate var isTitleVisible: Bool {
        return hasText || isError || _titleVisible
    }
    
    fileprivate func updateAttributedPlaceholder() {
        guard let placeholder = placeholder,
            let font = placeholderFont ?? font else {
                return
        }
        attributedPlaceholder = placeholder.attr.font(font).textColor(placeholderColor)
    }
    
    fileprivate func updateControl(animated: Bool) {
        updateLineAndTitleColor()
        updateLineView()
        updateTitleLabel()
        titleLabelVisibility(animated: animated)
    }
    
    fileprivate func updateLineView() {
        lineView.snp.updateConstraints { (make) in
            make.height.equalTo(editingOrSelected ? selectedLineHeight : lineHeight)
        }
    }
    
    fileprivate func updateTitleLabel() {
        var titleText: String?
        if isError {
            titleText = errorMessage
        }else if editingOrSelected {
            titleText = selectedTitle ?? title ?? placeholder
        }else {
            titleText = title ?? placeholder
        }
        titleLabel.text = titleText
    }
    
    fileprivate func titleLabelVisibility(animated: Bool = false) {
        let rect = placeholderRect(forBounds: bounds)
        let animate = { () -> Void in
            self.titleLabel.y = self.isTitleVisible ? 0 : rect.origin.y
            self.titleLabel.transform = self.isTitleVisible ? CGAffineTransform(scaleX: 0.8, y: 0.8) : CGAffineTransform.identity
            self.titleLabel.x = 0
        }
        if animated {
            UIView.animate(withDuration: isTitleVisible ? titleFadeInDuration : titleFadeOutDuration, animations: animate)            
        }else {
            animate()
        }
    }
    
    fileprivate func updateLineAndTitleColor() {
        // line
        if isError {
            lineView.backgroundColor = errorColor
        }else {
            lineView.backgroundColor = editingOrSelected ? selectedLineColor : lineColor
        }
        
        // title
        if isError {
            titleLabel.textColor = errorColor
        }else if editingOrSelected || isHighlighted {
            titleLabel.textColor = selectedTitleColor
        }else {
            titleLabel.textColor = titleColor
        }
    }
}

// MARK: - Layout subviews
extension AnimatedTextField {
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        borderStyle = .none
        isSelected = true
        _renderingInInterfaceBuilder = true
        updateLineAndTitleColor()
        updateControl(animated: false)
        invalidateIntrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = placeholderRect(forBounds: bounds)
        titleLabel.y = (isTitleVisible || _renderingInInterfaceBuilder) ? 0 : rect.origin.y
        titleLabel.height = (isTitleVisible || _renderingInInterfaceBuilder) ? titleFont.lineHeight : rect.size.height
        
        
        if clearButtonMode != .never {
            let clearButton = value(forKeyPath: "_clearButton") as! UIButton
            clearButton.origin.y += titleFont.lineHeight / 2
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: titleFont.lineHeight + font!.lineHeight + 7)
    }
}

// MARK: - Text position
extension AnimatedTextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        let titleHeight = titleFont.lineHeight
        let lineHeight = selectedLineHeight
        let rightViewRect = self.rightViewRect(forBounds: bounds)
        let rect = CGRect(x: 0, y: titleHeight, width: bounds.width - rightViewRect.size.width, height: bounds.height - titleHeight - lineHeight)
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        let titleHeight = titleFont.lineHeight
        let lineHeight = selectedLineHeight
        let rightViewRect = self.rightViewRect(forBounds: bounds)
        let rect = CGRect(x: 0, y: titleHeight, width: bounds.width - rightViewRect.size.width - 15, height: bounds.height - titleHeight - lineHeight)
        return rect
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        super.placeholderRect(forBounds: bounds)
        let titleHeight = titleFont.lineHeight
        let lineHeight = selectedLineHeight
        let rightViewRect = self.rightViewRect(forBounds: bounds)
        let rect = CGRect(x: 0, y: titleHeight, width: bounds.width - rightViewRect.size.width, height: bounds.height - titleHeight - lineHeight)
        return rect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        let titleHeight = titleFont.lineHeight
        rect.origin.y += titleHeight / 2
        return rect
    }
}

extension UITextField {
    
    func fixCaretPosition() {
        let beginning = beginningOfDocument
        selectedTextRange = textRange(from: beginning, to: beginning)
        let end = endOfDocument
        selectedTextRange = textRange(from: end, to: end)
    }
}
