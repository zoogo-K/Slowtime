//
//  UIView+hexa.swift
//  hexa
//
//  Created by KKING on 16/8/3.
//  Copyright © 2016年 vincross. All rights reserved.
//



import Foundation
import UIKit

private func convertPoint(_ point: CGPoint, add x: CGFloat) -> CGPoint {
    return CGPoint(x: point.x + x, y: point.y)
}

extension UIView {
    func incorrectPasswordShakeAnimation() {
        let path = UIBezierPath()
        path.move(to: center)
        [15, 10, 5].forEach {
            path.addLine(to: convertPoint(center, add: CGFloat($0)))
            path.addLine(to: center)
            path.addLine(to: convertPoint(center, add: CGFloat(-$0)))
        }
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "position")
        keyframeAnimation.path = path.cgPath
        keyframeAnimation.duration = 0.2
        keyframeAnimation.repeatCount = 1
        keyframeAnimation.isRemovedOnCompletion = true
        layer.add(keyframeAnimation, forKey: "shake")
    }
}

extension UIView {
    @discardableResult
    func addUnderLine() -> UIView {
        let view: UIView = UIView()
        view.backgroundColor = .hexaNormalSeparatorLine
        addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        return self
    }
}

extension UIView {
    public var x: CGFloat{
        get{
            return frame.origin.x
        }
        set{
            var r = frame
            r.origin.x = newValue
            frame = r
        }
    }
    
    public var y: CGFloat{
        get{
            return frame.origin.y
        }
        set{
            var r = frame
            r.origin.y = newValue
            frame = r
        }
    }
    /// 右边界的x值
    public var rightX: CGFloat{
        get{
            return x + width
        }
        set{
            var r = frame
            r.origin.x = newValue - frame.size.width
            frame = r
        }
    }
    /// 下边界的y值
    public var bottomY: CGFloat{
        get{
            return y + height
        }
        set{
            var r = frame
            r.origin.y = newValue - frame.size.height
            frame = r
        }
    }
    
    public var centerX : CGFloat{
        get{
            return center.x
        }
        set{
            center = CGPoint(x: newValue, y: center.y)
        }
    }
    
    public var centerY : CGFloat{
        get{
            return center.y
        }
        set{
            center = CGPoint(x: center.x, y: newValue)
        }
    }
    
    public var width: CGFloat{
        get{
            return frame.size.width
        }
        set{
            var r = frame
            r.size.width = newValue
            frame = r
        }
    }
    public var height: CGFloat{
        get{
            return frame.size.height
        }
        set{
            var r = frame
            r.size.height = newValue
            frame = r
        }
    }
    
    
    public var origin: CGPoint{
        get{
            return frame.origin
        }
        set{
            x = newValue.x
            y = newValue.y
        }
    }
    
    public var size: CGSize{
        get{
            return frame.size
        }
        set{
            width = newValue.width
            height = newValue.height
        }
    }
    
}
