//
//  FontLayout+ST.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public extension FontLayout {
    static var regular: UIFont = {
        return UIFont.systemFont(ofSize: 18.0)
    }()
    
    static var bold: UIFont = {
        return UIFont.boldSystemFont(ofSize: 20.0)
    }()

    static var title: UIFont = {
        return UIFont.systemFont(ofSize: 30.0)
    }()
    
    static var subtitle: UIFont = {
        return UIFont.systemFont(ofSize: 14.0)
    }()
    
    static var tabItem: UIFont = {
        return UIFont.systemFont(ofSize: 14.0)
    }()
}
