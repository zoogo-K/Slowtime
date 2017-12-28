//
//  String+hexa.swift
//  hexa
//
//  Created by KKING on 16/8/5.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func font(_ font: UIFont, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttributes([NSAttributedStringKey.font: font], range: range ?? textRange)
        return self
    }
    
    func textColor(_ textColor: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttributes([NSAttributedStringKey.foregroundColor: textColor], range: range ?? textRange)
        return self
    }
    
    func lineSpace(_ lineSpace: CGFloat, range: NSRange? = nil) -> NSMutableAttributedString {
        guard !string.isEmpty else { return self }
        let paragraph = (attribute(NSAttributedStringKey.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle) ?? (NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle)
        paragraph.lineSpacing = lineSpace
        addAttributes([NSAttributedStringKey.paragraphStyle: paragraph], range: range ?? textRange)
        
        return self
    }
    
    func alignment(_ alignment: NSTextAlignment, range: NSRange? = nil) -> NSMutableAttributedString {
        guard !string.isEmpty else { return self }
        let paragraph = (attribute(NSAttributedStringKey.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle) ?? (NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle)
        paragraph.alignment = alignment
        addAttributes([NSAttributedStringKey.paragraphStyle: paragraph], range: range ?? textRange)
        return self
    }
    
    func underlineStyle(_ underlineStyle: NSUnderlineStyle, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttributes([NSAttributedStringKey.underlineStyle: underlineStyle.rawValue], range: range ?? textRange)
        return self
    }
    
    func baselineOffset(_ offset: Int, range: NSRange? = nil) -> NSMutableAttributedString {
        addAttribute(NSAttributedStringKey.baselineOffset, value: NSNumber(integerLiteral: offset), range: range ?? textRange)
        return self
    }
    
    fileprivate var textRange: NSRange {
        return NSMakeRange(0, length)
    }
    
}

extension String {
    
    var attr: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    func stringRect(with font:UIFont = .systemFont(ofSize: 12) , size:CGSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity))->CGSize{
        let attrStr = attr.font(font)
        return attrStr.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size
    }
}

extension String {
    
    func StringToCGFloat()->(CGFloat){
        
        var cgFloat: CGFloat = 0
        
        if let doubleValue = Double(self)
        {
            cgFloat = CGFloat(doubleValue)
        }
        return cgFloat
    }
    
    
    func StringToDictionary() ->NSDictionary{
        
        let jsonData:Data = self.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    
}
