//
//  ViewStatusPredictive.swift
//  STDemos
//
//  Created by Luca Pezzoni on 27/10/2026.
//

import Foundation
import STBlueSDK

public struct ViewStatusPredictive  {
    let xStatus: PredictiveStatus?
    let yStatus: PredictiveStatus?
    let zStatus: PredictiveStatus?
    
    let x: PointPredictive?
    let y: PointPredictive?
    let z: PointPredictive?
    
    init(xStatus: PredictiveStatus? = nil, yStatus: PredictiveStatus? = nil, zStatus: PredictiveStatus? = nil, x: PointPredictive? = nil, y: PointPredictive? = nil, z: PointPredictive? = nil) {
        self.xStatus = xStatus
        self.yStatus = yStatus
        self.zStatus = zStatus
        self.x = x
        self.y = y
        self.z = z
    }
}
