//
//  DataSampleProvider.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public typealias GenericSampleHandler = ([GenericSample]) -> Void
public typealias GenericClosedRangeHandler = (ClosedRange<Double>?) -> Void

public protocol GenericSampleProvider {
    func getSamples(completion: @escaping GenericSampleHandler)
    func getRange(completion: @escaping GenericClosedRangeHandler)
}

public class DeviceGenericSampleProvider: GenericSampleProvider {
    private let sampleHandler: (@escaping GenericSampleHandler) -> Void
    private let rangeHandler: ((@escaping GenericClosedRangeHandler) -> Void)?

    public init(sampleHandler: @escaping (@escaping GenericSampleHandler) -> Void,
                rangeHandler: ((@escaping GenericClosedRangeHandler) -> Void)? = nil) {
        self.sampleHandler = sampleHandler
        self.rangeHandler = rangeHandler
    }
    
    public func getSamples(completion: @escaping GenericSampleHandler) {
        sampleHandler(completion)
    }
    
    public func getRange(completion: @escaping GenericClosedRangeHandler) {
        guard let rangeHandler = rangeHandler else {
            return completion(nil)
        }
        
        rangeHandler(completion)
    }
}
