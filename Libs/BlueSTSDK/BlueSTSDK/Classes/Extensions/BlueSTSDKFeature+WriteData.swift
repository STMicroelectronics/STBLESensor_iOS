//
//  BlueSTSDKFeature+WriteData.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 24/02/21.
//

import Foundation

extension BlueSTSDKFeature {
    func writeBytes(_ data: Data, completion: @escaping (Bool) -> Void) {
        guard let char = parentNode.extractCharacteristics(from: self),
              BlueSTSDKNode.charCanBeWrite(char) else { completion(false); return }
        
        let writeType = BlueSTSDKNode.getWriteType(forChar: char)
        parentNode.getPeripheral()?.writeValue(data, for: char, type: writeType)
        
        //  Wait some times otherwise data is not received correctly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion(true)
        }
    }
}
