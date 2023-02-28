/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

import UIKit

struct STDefaultTheme: Theme {
    var color: Colors = STDefaultColors()
    var font: Font = STDefaultFont()
}

public func bundle() -> Bundle {
    let myBundle = Bundle(for: ThemeService.self)
    
    guard let resourceBundleURL = myBundle.url(forResource: "STThemeResources", withExtension: "bundle") else {
        fatalError("STThemeResources.bundle not found!")
    }
    
    guard let resourceBundle = Bundle(url: resourceBundleURL) else {
        fatalError("Cannot access STThemeResources.bundle!")
    }
    
    return resourceBundle
}

private func assetColor(colorName: String) -> UIColor{
    return UIColor(named: colorName, in: bundle(), compatibleWith:nil)!
}

struct STDefaultColors: Colors {

    let primary = UIColor(named: "primary", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#3CB4E6FF") ?? UIColor(hex: "#3CB4E6FF")!
    let secondary = UIColor(named: "accent", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#E6007EFF")!
    let secondaryATR = UIColor(named: "primary_dark", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#03234BFF")!
    
    var background:UIColor {
        if #available(iOS 13, *){
            return UIColor.systemBackground
        }
        return UIColor(named: "background", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#B6DBF4FF")!
    }
    var text:UIColor {
        if #available(iOS 13, *) {
            return UIColor.label
        }
        return UIColor(named: "text", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#74757CFF")!
    }
    var secondaryText: UIColor {
        if #available(iOS 13, *) {
            return UIColor.secondaryLabel
        }
        return UIColor.gray
    }
    let textDark = UIColor(named: "textDark", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#464650FF")!
    let error = UIColor(named: "error", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#F75343FF")!
    var cardPrimary:UIColor {
        if #available(iOS 13, *){
            return UIColor{ uiTrait in
                if(uiTrait.userInterfaceStyle == .dark){
                    return UIColor.secondarySystemGroupedBackground
                }else{
                    return .white
                }
            }//ui color
        }//ios 13
        return .white
    }
    
    var cardSecondary:UIColor {
        if #available(iOS 13, *){
           return UIColor{ uiTrait in
               if(uiTrait.userInterfaceStyle == .dark){
                   return UIColor.tertiarySystemGroupedBackground
               }else{
                   return UIColor(named: "card_secondary", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#D1D0D3FF")!
               }
           }//ui color
       }//ios 13
        return UIColor(named: "card_secondary", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#D1D0D3FF")!
    }
    
    let navigationBar = UIColor(named: "primary", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#3CB3E6FF")!
    let navigationBarText = UIColor(named: "primary_dark", in: bundle(), compatibleWith:nil) ?? UIColor(hex: "#03234BFF")!
    var viewControllerBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return UIColor.white
        }
    }
}

struct STDefaultFont: Font {
    var regular: UIFont = UIFont.systemFont(ofSize: 15.0)
    var bold: UIFont = UIFont.boldSystemFont(ofSize: 15.0)
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
