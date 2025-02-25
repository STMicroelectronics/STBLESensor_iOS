//
//  BinaryContentDelegate.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK
import STUI

public protocol BinaryContentDelegate: DemoDelegate {
    
    func load()
    
    //var disableNotificationOnDisappear: Bool { get set }
    
    func updatePnPL(with feature: PnPLFeature)
    
    func updateBinaryContent(with feature: BinaryContentFeature)
    
    func loadFromFile()
    
    func saveToFile(fileName: String?)
    
    func sendToBoard(bleChunkWriteSize: Int)
    
    func getBinaryContentMaxWriteLength() -> Int
    
}
