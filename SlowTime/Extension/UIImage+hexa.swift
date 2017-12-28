//
//  UIImage+hexa.swift
//  hexa
//
//  Created by KKING on 16/8/9.
//  Copyright © 2016年 vincross. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {
    
    static func qrImage(with string: String!, imageName: String?) -> UIImage? {
        DLog(string)
        let stringData = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        let qrCIImage = qrFilter.outputImage
        
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(qrCIImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        
        let codeImage = UIImage(ciImage: colorFilter.outputImage!
            .transformed(by: CGAffineTransform(scaleX: 5, y: 5)))
        
        guard let imageName = imageName else {
            return codeImage
        }
        let iconImage = UIImage(named: imageName)
        let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
        UIGraphicsBeginImageContext(rect.size)
        defer { UIGraphicsEndImageContext() }
        codeImage.draw(in: rect)
        let avatarSize = CGSize(width: rect.size.width * 0.25, height: rect.size.height * 0.25)
        let x = (rect.width - avatarSize.width) * 0.5
        let y = (rect.height - avatarSize.height) * 0.5
        iconImage!.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return resultImage
    }
    
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.setFillColor(color.cgColor)
        contextRef?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        let cgImage = image?.cgImage
//        guard let cgImage = image?.cgImage else { return nil }
        
        self.init(cgImage: cgImage!, scale: UIScreen.main.scale, orientation: .up)
    }
    
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        var size = size
        var rect = CGRect(x: 0, y: 0, width: size.width, height: size.height).standardized
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var scale: CGFloat
        if (size.width / size.height < rect.size.width / rect.size.height) {
            scale = rect.size.height / size.height;
        } else {
            scale = rect.size.width / size.width;
        }
        size.width *= scale
        size.height *= scale
        rect.size = size
        rect.origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            context.addRect(rect)
            context.clip()
            draw(in: rect)
            context.restoreGState()
        }else {
            draw(in: rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    func crop(to rect: CGRect) -> UIImage? {
        let newRect = CGRect(x: rect.origin.x * scale,
                             y: rect.origin.y * scale,
                             width: rect.size.width * scale,
                             height: rect.size.height * scale)
        guard newRect.width > 0 && newRect.height > 0 else { return nil }
        guard let imageRef = cgImage!.cropping(to: newRect) else { return nil }
        return UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        
    }
    
    func withCornerRadius(_ radius: CGFloat!,
        corners: UIRectCorner! = .allCorners,
        borderWidth: CGFloat! = 0,
        borderColor: UIColor? = nil,
        borderLineJoin: CGLineJoin! = .miter)
    -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext();
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -rect.size.height)
        
        let minSize = min(size.width, size.height)
        if (borderWidth < minSize / 2) {
            let path = UIBezierPath(roundedRect: rect.insetBy(dx: borderWidth, dy: borderWidth), byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: borderWidth))
            path.close()
            context?.saveGState()
            path.addClip()
            context?.draw(cgImage!, in: rect)
            context?.restoreGState()
        }
        
        if (borderColor != nil && borderWidth < minSize / 2 && borderWidth > 0) {
            let strokeInset = (floor(borderWidth * scale) + 0.5) / scale;
            let strokeRect = rect.insetBy(dx: strokeInset, dy: strokeInset)
            let strokeRadius = radius > self.scale / 2 ? radius - self.scale / 2 : 0;
            let path = UIBezierPath(roundedRect: strokeRect, byRoundingCorners: corners, cornerRadii: CGSize(width: strokeRadius, height: borderWidth))
            path.close()
            
            path.lineWidth = borderWidth;
            path.lineJoinStyle = borderLineJoin;
            borderColor?.setStroke()
            path.stroke()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image!
    }
    
}
