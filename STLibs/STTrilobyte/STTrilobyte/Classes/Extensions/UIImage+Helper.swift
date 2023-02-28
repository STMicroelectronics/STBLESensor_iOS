//
//  UIImage+Extension.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

public extension UIImage {
    
    static func named(_ name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle(for: SensorTile101ViewController.self), compatibleWith: nil)
    }
    
    static func from(_ color: UIColor, width: CGFloat = 1.0, height: CGFloat = 1.0) -> UIImage? {
        
        var image: UIImage?
        
        let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        
        UIGraphicsBeginImageContext(rect.size)
        
        if let context: CGContext = UIGraphicsGetCurrentContext() {
            
            context.setFillColor(color.cgColor)
            context.fill(rect)
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return image
    }
}
