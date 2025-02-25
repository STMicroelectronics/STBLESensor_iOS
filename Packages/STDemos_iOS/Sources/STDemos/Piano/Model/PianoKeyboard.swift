//
//  PianoKeyboard.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public class PianoKeyboard: ObservableObject {
    static let numberWhiteKeys = 14
    static let numberBlackKeys = 10
    
    private  let keyByte: [Int8] = [
        1, //NOTE_C1
        2, // NOTE_CS1
        3, // NOTE_D1
        4, // NOTE_DS1
        5, // NOTE_E1
        6, // NOTE_F1
        7, // NOTE_FS1
        8, // NOTE_G1
        9, // NOTE_GS1
        10, // NOTE_A1
        11, // NOTE_AS1
        12, // NOTE_B1
        13, // NOTE_C2
        14, // NOTE_CS2
        15, // NOTE_D2
        16, // NOTE_DS2
        17, // NOTE_E2
        18, // NOTE_F2
        19, // NOTE_FS2
        20, // NOTE_G2
        21, // NOTE_GS2
        22, // NOTE_A2
        23, // NOTE_AS2
        24 // NOTE_B2
    ]
    
    @Published var whiteKeys: [PianoKey] = []
    @Published var blackKeys: [PianoKey] = []
    
    init() {
        var keyNum = 0
        
        for key in 0..<PianoKeyboard.numberWhiteKeys {
            whiteKeys.append(PianoKey(sound: keyByte[keyNum]))
            keyNum+=1
            if (key != 2 && key != 6 && key != 9 && key != 13) {
                blackKeys.append(PianoKey(sound: keyByte[keyNum]))
                keyNum+=1
            }
        }
    }
    
    func updateKeyDimensions(geometry: GeometryProxy?) {
        if geometry != nil {
            let width = geometry!.size.width
            let height = geometry!.size.height
            let keyHeight = height / CGFloat(PianoKeyboard.numberWhiteKeys)
            var blackKeyNum = 0
            
            
            for key in 0..<PianoKeyboard.numberWhiteKeys {
                whiteKeys[key].centerX = width * 0.5
                whiteKeys[key].centerY = CGFloat(key) * keyHeight + keyHeight*0.5
                whiteKeys[key].width = width
                whiteKeys[key].height = keyHeight
                if (key != 2 && key != 6 && key != 9 && key != 13) {
                    blackKeys[blackKeyNum].centerX = width * 0.7
                    blackKeys[blackKeyNum].centerY = CGFloat(key+1) * keyHeight
                    blackKeys[blackKeyNum].width = width * 0.6
                    blackKeys[blackKeyNum].height = keyHeight * 0.7
                    blackKeyNum += 1
                }
            }
        }
    }
}
