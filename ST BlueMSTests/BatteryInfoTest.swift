//
//  BatteryInfoTest.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 03/05/2017.
//  Copyright © 2017 STMicroelectronics. All rights reserved.
//

import Foundation
import XCTest
@testable import ST_BlueMS

class BatteryInfoTest : XCTestCase {
    
    
    func testEmptyStringReturnEmptyArray(){
        let infos = W2STBoardStatusBoardInfo.parse("")
        XCTAssertTrue(infos.isEmpty)
    }
    
    
    
}
