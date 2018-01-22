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
    
    
    
    func textHeight(with font:UIFont ,width: CGFloat) -> CGFloat {
        
        let normalText: String = self
        let size = CGSize(width: width, height: 1000)
        let dic = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedStringKey : Any], context:nil).size
        return stringSize.height
    }
    
}

extension String {
    
    func StringFormartTime()-> String {
        
        let subStrArr = components(separatedBy: "-")
        var newStr = ""
        for index in 0 ..< subStrArr.count {
            switch index {
            case 0: newStr += subStrArr[0] + "年"
            case 1: newStr += subStrArr[1] + "月"
            case 2: newStr += subStrArr[2] + "号"
            default:()
            }
        }
        return newStr
    }
    
    
    func StringToZipCode()-> String {
        var newStr = ""
        for index in 0 ..< self.count {
            newStr += self[self.index(self.startIndex, offsetBy: index)..<self.index(self.startIndex, offsetBy: index + 1)]  + "  "
        }
        return newStr
    }
    
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
