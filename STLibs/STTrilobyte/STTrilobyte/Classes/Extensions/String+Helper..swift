//
//  STRING+HELPER.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 28/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation

extension String {
    
    func withoutTerminator() -> String {
        return self.replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "")
    }
}
