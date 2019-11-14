//
//  BlueMSAudioFeatures.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 09/10/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation

struct BlueMSAudioFeatures{
    let audioStream:(BlueSTSDKFeature & BlueSTSDKAudioDecoder);
    let controlData:BlueSTSDKFeature;
    
    static func extractOpusFeatures(from node:BlueSTSDKNode) -> BlueMSAudioFeatures?{
        if let audio = node.getFeatureOfType(BlueSTSDKFeatureAudioOpus.self) as? BlueSTSDKFeatureAudioOpus,
            let audioSync = node.getFeatureOfType(BlueSTSDKFeatureAudioOpusConf.self){
            return BlueMSAudioFeatures(audioStream: audio, controlData: audioSync)
        } else {
            return nil
        }
    }
    
    static func extractADPCFeatures(from node:BlueSTSDKNode) -> BlueMSAudioFeatures?{
        if let audio = node.getFeatureOfType(BlueSTSDKFeatureAudioADPCM.self) as? BlueSTSDKFeatureAudioADPCM,
            let audioSync = node.getFeatureOfType(BlueSTSDKFeatureAudioADPCMSync.self){
            return BlueMSAudioFeatures(audioStream: audio, controlData: audioSync)
        } else {
            return nil
        }
    }
    
    static func extractBestFeatures(from node:BlueSTSDKNode) -> BlueMSAudioFeatures?{
        if let opusFeature = extractOpusFeatures(from: node){
            return opusFeature
        } else {
            return extractADPCFeatures(from: node)
        }
    }
    
}
