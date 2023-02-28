//
//  BlueSTSDKFeatureAudio.swift
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 03/10/2019.
//  Copyright © 2019 STCentralLab. All rights reserved.
//

import Foundation

public protocol BlueSTSDKAudioCodecSettings {
    var codecName:String {get}
    /// codec frequency in hz
    var samplingFequency:Int {get}
    /// number of audio channel into the streaming
    var channels:Int {get}
    /// byte used to rappresent an audio sample
    var bytesPerSample:Int {get}
    /// decoded bytes obtined after each ble ble notification
    var samplePerBlock:Int {get}
}

public protocol BlueSTSDKAudioCodecManager : BlueSTSDKAudioCodecSettings {    
    var isAudioEnabled:Bool {get}
    func reinit()
    func updateParameters(from: BlueSTSDKFeatureSample)
}

public protocol BlueSTSDKAudioDecoder {
    func getAudio(from: BlueSTSDKFeatureSample)->Data?
    var codecManager:BlueSTSDKAudioCodecManager {get}
}
