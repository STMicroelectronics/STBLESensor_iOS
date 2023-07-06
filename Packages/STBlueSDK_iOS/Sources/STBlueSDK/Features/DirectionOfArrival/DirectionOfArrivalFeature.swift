//
//  DirectionOfArrivalFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class DirectionOfArrivalFeature: BaseFeature<DirectionOfArrivalData> {
    
    let packetLength = 2
    
    public var commands: [FeatureCommandType] = [
        DirectionOfArrivalCommand.changeSensitivity(sentivity: .lowSensitivity),
        DirectionOfArrivalCommand.changeSensitivity(sentivity: .highSensitivity)
    ]
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
    
        if data.count - offset < packetLength {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        let parsedData = DirectionOfArrivalData(with: data, offset: offset)
        
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), packetLength)
    }

}
