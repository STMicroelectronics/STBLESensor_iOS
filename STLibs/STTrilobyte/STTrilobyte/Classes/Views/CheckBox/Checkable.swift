//
//  Checkable.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 11/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

protocol Checkable {
    var identifier: String { get }
    var descr: String { get }
}

struct FakeCheckable: Checkable {
    var identifier = ""
    var descr = ""
}
