//
//  DataSampleProvider.swift
//  AssetTrackingDataModel
//
//  Created by Klaus Lanzarini on 10/11/2020.
//

import Foundation

public typealias SampleHandler = ([DataSample]) -> Void
public typealias ClosedRangeHandler = (ClosedRange<Double>?) -> Void

public protocol DataSampleProvider {
    func getSamples(completion: @escaping SampleHandler)
    func getRange(completion: @escaping ClosedRangeHandler)
}

public class DeviceDataSampleProvider: DataSampleProvider {
    private let sampleHandler: (@escaping SampleHandler) -> Void
    private let rangeHandler: ((@escaping ClosedRangeHandler) -> Void)?

    public init(sampleHandler: @escaping (@escaping SampleHandler) -> Void,
                rangeHandler: ((@escaping ClosedRangeHandler) -> Void)? = nil) {
        self.sampleHandler = sampleHandler
        self.rangeHandler = rangeHandler
    }
    
    public func getSamples(completion: @escaping SampleHandler) {
        sampleHandler(completion)
    }
    
    public func getRange(completion: @escaping ClosedRangeHandler) {
        guard let rangeHandler = rangeHandler else {
            return completion(nil)
        }
        
        rangeHandler(completion)
    }
}
