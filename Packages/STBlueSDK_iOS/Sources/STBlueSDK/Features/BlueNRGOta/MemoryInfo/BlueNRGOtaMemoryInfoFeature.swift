//
//  BlueNRGOtaMemoryInfoFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class BlueNRGOtaMemoryInfoFeature: TimestampFeature<BlueNRGOtaMemoryInfoData> {
    
    public required init(name: String, type: FeatureType) {
        super.init(name: name, type: type)
        isDataNotifyFeature = false
    }

    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        if data.count - offset < 8 {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        let parsedData = BlueNRGOtaMemoryInfoData(with: data, offset: offset)
        
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), data.count)
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }

}
