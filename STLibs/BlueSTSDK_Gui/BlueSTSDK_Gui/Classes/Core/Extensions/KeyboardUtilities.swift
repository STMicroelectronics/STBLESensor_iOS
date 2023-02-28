//
//  KeyboardUtilities.swift
//  BlueSTSDK_Gui
//
//  Created by Dimitri Giani on 27/05/21.
//

import Foundation

public class KeyboardUtilities {
    public static func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyBoardSizeValue = (userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)
        let keyBoardSize = keyBoardSizeValue?.cgRectValue.size ?? CGSize(width: 0, height: 0)
        return keyBoardSize.height
    }
}
