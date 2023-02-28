//
//  Bool+Extensions.swift
//  AppAuth
//
//  Created by Dimitri Giani on 30/04/21.
//

import Foundation

public extension Bool {
    var string: String {
        self == true ? "true" : "false"
    }
}
