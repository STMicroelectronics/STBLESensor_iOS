//
//  SmarTag2IO.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol SmarTag2IO {
    typealias IOResult = Result<Data,SmarTagIOError>
    
    func read(address: Int, onComplete: @escaping (IOResult)->Void)
    func read(range: Range<Int>, onComplete: @escaping (IOResult)->Void)
    func writeExtendedSingleBlock(startAddress:Int, data: Data, onComplete:@escaping (SmarTagIOError?)->Void)
}
