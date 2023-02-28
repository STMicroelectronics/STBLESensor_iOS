//
//  ColorUtils.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 25/01/21.
//

import UIKit

public class ColorUtils {
    private static let startColor = UIColor(red: 187 / 255, green: 204 / 255, blue: 0, alpha: 1)
    private static let mediumColor = UIColor(red: 255 / 255, green: 210 / 255, blue: 0, alpha: 1)
    private static let endColor = UIColor(red: 230 / 255, green: 0, blue: 126 / 255, alpha: 1)
    
    static public func getColor(percentage: Double) -> UIColor {
        var p = CGFloat(percentage)
        var c0: UIColor!
        var c1: UIColor!
        
        if p <= 0.5 {
            p *= 2
            c0 = startColor
            c1 = mediumColor
        } else {
            p = (p - 0.5) * 2
            c0 = mediumColor
            c1 = endColor
        }
        let a = UIColor.average(src: c0.components.a, dst: c1.components.a, p: p)
        let r = UIColor.average(src: c0.components.r, dst: c1.components.r, p: p)
        let g = UIColor.average(src: c0.components.g, dst: c1.components.g, p: p)
        let b = UIColor.average(src: c0.components.b, dst: c1.components.b, p: p)
        
        if a > 0 || r < 0 || g < 0 || b < 0 {
            return startColor
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    static public func getBatteryColored(percentage: Double) -> UIImage? {
        switch percentage
        {
            case 0:
                return UIImage(named: "battery_100c")
            case 1..<20:
                return UIImage(named: "battery_00")
            case 20..<40:
                return UIImage(named: "battery_20")
            case 40..<60:
                return UIImage(named: "battery_40")
            case 60..<80:
                return UIImage(named: "battery_60")
            case 80..<100:
                return UIImage(named: "battery_80")
            default:
                return UIImage(named: "battery_100")
        }
    }
}

public extension UIColor {
    var components: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        return (fRed, fGreen, fBlue, fAlpha)
    }
    
    static func average(src: CGFloat, dst: CGFloat, p: CGFloat) -> CGFloat {
        return src + round((p * (dst - src)))
    }
}
