
import UIKit

final class HexaHUD {
    
    private static let shared = HexaHUD()
    
    private let labelBackgroundView: UIView = {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        $0.layer.cornerRadius = 3
        return $0
    }(UIView())
    
    private let textLabel: UILabel = {
        $0.numberOfLines = 0
        $0.textColor = .white
        return $0
    }(UILabel())
    
    private let backView: UIView = {
        $0.isUserInteractionEnabled = false
        $0.alpha = 0
        return $0
    }(UIView())
    
    private init() {
        
        backView.addSubview(labelBackgroundView)
        labelBackgroundView.addSubview(textLabel)
        
        labelBackgroundView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualTo(227)
            make.width.greaterThanOrEqualTo(117)
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.edges.equalTo(UIEdgeInsets(top: 21, left: 23, bottom: 21, right: 23))
        }
    }
    
    
    static func show(with text: String, in view: UIView? = UIApplication.shared.keyWindow) {
        guard let view = view else { return }
        DispatchQueue.main.async {
            view.endEditing(true)
            view.addSubview(HexaHUD.shared.backView)
            HexaHUD.shared.backView.snp.makeConstraints({ (make) in
                make.top.left.right.bottom.equalToSuperview()
            })
            
            HexaHUD.shared.textLabel.attributedText = text.attr.font(.my_systemFont(ofSize: 14)).lineSpace(3).alignment(.center)
            
            
            UIView.animate(withDuration: 0.25, animations: {
                HexaHUD.shared.backView.alpha = 1
            }, completion: { (_) in
                UIView.animate(withDuration: 0.25, delay: 1, options: [], animations: {
                    HexaHUD.shared.backView.alpha = 0
                }, completion: { (_) in
                    DispatchQueue.main.async {
                        HexaHUD.shared.backView.removeFromSuperview()
                        HexaHUD.shared.textLabel.attributedText = nil
                    }
                })
            })
        }
    }
}
