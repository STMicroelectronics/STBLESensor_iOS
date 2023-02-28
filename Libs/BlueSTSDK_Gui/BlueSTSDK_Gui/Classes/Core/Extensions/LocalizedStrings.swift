//
//  LocalizedStrings.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 25/01/21.
//

import UIKit

public extension String {
    var localizedFromGUI: String {
        return localizedFromGUI()
    }
    
    func localizedFromGUI(_ tableName:String = "", value:String = "", comment:String = "", arguments:[CVarArg]? = nil) -> String
    {
        var localizedString = NSLocalizedString(self, tableName: tableName, bundle: BlueSTSDK_Gui.bundle(), value: value, comment: comment)
        
        if let arguments = arguments, arguments.count > 0
        {
            localizedString = String(format: localizedString, arguments: arguments)
        }
        
        return localizedString
    }
}
