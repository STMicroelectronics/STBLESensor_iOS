//
//  UIImage+Extensions.swift
//
//  Created by Dimitri Giani on 13/01/21.
//

import UIKit

public extension UIImage {
    static func namedFromGUI(_ named: String) -> UIImage? {
        return UIImage(named: named, in: BlueSTSDK_Gui.bundle(), compatibleWith: nil)
    }
}
