//
//  ECFeatureSample.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 28/04/21.
//

import Foundation

public class ECFeatureSample: BlueSTSDKFeatureSample {
    public let response: ECResponse
    
    public init(response: ECResponse) {
        self.response = response
        
        super.init()
    }
}
