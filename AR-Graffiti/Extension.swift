//
//  Extension.swift
//  AR-Graffiti
//
//  Created by yoga on 2018/8/14.
//  Copyright © 2018年 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
    
    return left + (right * -1.0)
}

func *(vector:SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
    
    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}

extension CGSize {
    var normalized:CGSize {
        get {
            let length = sqrt(width * width + height * height)
            
            return CGSize(width: width / length,
                          height: height / length)
        }
    }
}

func +(left:CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x,
                   y: left.y + right.y)
}

func -(left:CGPoint, right:CGPoint) -> CGPoint {
    
    return left + (right * -1.0)
}

func *(vector:CGPoint, multiplier:CGFloat) -> CGPoint {
    
    return CGPoint(x: vector.x * multiplier,
                   y: vector.y * multiplier)
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func distance(vector: CGPoint) -> CGFloat {
        return (self - vector).length()
    }
}

extension SCNVector3 {
    
    func dotProduct(_ vectorB:SCNVector3) -> SCNFloat {
        
        return (x * vectorB.x) + (y * vectorB.y) + (z * vectorB.z)
    }
    
    var magnitude:SCNFloat {
        get {
            return sqrt(dotProduct(self))
        }
    }
    
    var normalized:SCNVector3 {
        get {
            let localMagnitude = magnitude
            let localX = x / localMagnitude
            let localY = y / localMagnitude
            let localZ = z / localMagnitude
            
            return SCNVector3(localX, localY, localZ)
        }
    }
    
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    func distance(vector: SCNVector3) -> Float {
        return (self - vector).length()
    }
}

extension UIImage {
    func imageWithSize(_ size:CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

extension UIAlertController{
    
    func addImage(image: UIImage){
        let maxSize = CGSize(width: 245, height: 300)
        let imgSize = image.size
        var ratio: CGFloat
        
        if (imgSize.width > imgSize.height){
            ratio = maxSize.width / imgSize.width
        }else{
            ratio = maxSize.height / imgSize.height
        }
        let scaledSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
        var resizedImage = image.imageWithSize(scaledSize)
        
        if (imgSize.height > imgSize.width){
            let left = (maxSize.width - resizedImage.size.width) / 2
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsetsMake(0, -left, 0, 0))
        }
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imgAction)
    }
}
