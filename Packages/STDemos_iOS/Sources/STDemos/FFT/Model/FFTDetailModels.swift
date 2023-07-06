//
//  FFTDetailModels.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI

public struct AlertFFTDetails {
    public let fftDetails: FFTDetails?
    public let callback: AlertActionClosure

    public init(fftDetails: FFTDetails?, callback: AlertActionClosure) {
        self.fftDetails = fftDetails
        self.callback = callback
    }
}

public struct FFTDetails {
    public var fftPoint: [FFTPoint]?
    public var fftTimeDataInfo: FFTTimeDataInfo?
}

public struct FFTPoint{
    public let frequency:Float
    public let amplitude:Float
    
    public init(frequency:Float, amplitude:Float) {
        self.frequency = frequency
        self.amplitude = amplitude
    }
}

public struct FFTTimeDataInfo {
    public let accX: String?
    public let accY: String?
    public let accZ: String?
    public let speedX: String?
    public let speedY: String?
    public let speedZ: String?

    public init(accX: String?, accY: String?, accZ: String?,
                speedX: String?, speedY: String?, speedZ: String?) {
        self.accX = accX
        self.accY = accY
        self.accZ = accZ
        self.speedX = speedX
        self.speedY = speedY
        self.speedZ = speedZ
    }
}

