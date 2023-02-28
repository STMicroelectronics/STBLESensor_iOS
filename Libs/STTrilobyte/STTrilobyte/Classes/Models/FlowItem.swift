//
//  FlowItem.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 29/03/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

protocol FlowItem {
    var identifier: String { get }
    var descr: String { get }
    var itemIcon: String { get }
    
    func hasSettings() -> Bool
}
