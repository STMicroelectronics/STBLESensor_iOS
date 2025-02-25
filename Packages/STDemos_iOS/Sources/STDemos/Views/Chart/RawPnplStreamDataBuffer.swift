//
//  RawPnplDataBuffer.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore
import STBlueSDK

public class RawPnplStreamDataBuffer {
    var channels: [RawPnplChannel] = []
    var odr: Int = 10 {
        didSet {
            odrBufferSize = odr / odrTimerNumberOfSlots
            //            visibleWindowSize = (odr * 5) < 100 ? 100 : (odr * 5)
            //            visibleWindowSize = visibleWindowSize > 500 ? 500 : visibleWindowSize
            visibleWindowSize = 300
        }
    }
    
    public let odrTimerInterval: TimeInterval = 0.1
    private var odrTimerNumberOfSlots: Int { Int(1 / odrTimerInterval) }
    
    public private (set) var odrBufferSize: Int = 0
    
    public private (set) var visibleWindowSize: Int = 0
    
    public var seekIndex: Int = 0
    
    public init() {
        
    }
    
    public  func reset() {
        channels.removeAll()
        seekIndex = 0
    }
    
    public var isDataReady: Bool {
        return (channels.first?.entries ?? []).count >= ((odr / odrTimerNumberOfSlots) + seekIndex)
    }
    
    public var nextAvailableData: [RawPnplChannel]? {
        if isDataReady {
            let entriesCount = channels.first?.entries.count ?? 0
            Logger.debug(text: "ENTRIES: \(entriesCount) SEEKINDEX: \(seekIndex) LENGHT: \(odrBufferSize) BUFFER: \(entriesCount - seekIndex)")
            let subChannels = channels.subChannels(from: seekIndex,
                                                   lenght: odrBufferSize)
            seekIndex = seekIndex + odrBufferSize
            
            return subChannels
        }
        
        return nil
    }
    
    public func addEntries(from rawStream: RawPnPLStreamEntry, uom: String?) {
        
        odr = (rawStream.odr ?? odrTimerNumberOfSlots).roundToClosestMultipleNumber(multiple: odrTimerNumberOfSlots)
        let streamChannels = rawStream.channels ?? 1
        
        if channels.isEmpty {
            for count in 0..<streamChannels {
                self.channels.append(RawPnplChannel(config: rawStream.lineConfigs[count], uom: uom ?? (rawStream.unit ?? "n/a")))
            }
        }
        
        var values: [[Float]] = []
        
        if rawStream.multiplyFactor != nil {
            values.append(contentsOf: rawStream.valueFloat.splitByChunk(streamChannels))
        } else {
            var temp = rawStream.value
            
            if temp.first is RawPnPLEnumLabel {
                temp.remove(at: 0)
            }
            
            let arrayOfArrayOfFloat: [[Float]] = temp.splitByChunk(streamChannels).map { array in
                let arrayOfFloat: [Float] = array.map { int in
                    return Float(int as! Int)
                }
                
                return arrayOfFloat
            }
            
            values.append(contentsOf: arrayOfArrayOfFloat)
        }
        
        for count in 0..<streamChannels {
            
            let transposed = values.reduce(into: Array(repeating: [Float](), count: values[0].count)) { result, current in
                guard current.count == values[0].count else {
                    fatalError("All subarrays must have the same length")
                }
                for (index, element) in current.enumerated() {
                    result[index].append(element)
                }
            }
            
            self.channels[count].addEntries(entries: transposed[count])
        }
    }
}

public class RawPnplChannel {
    public var entries: [Float] = []
    public var config: LineConfig
    public var uom: String
    
    public init(config: LineConfig, uom: String) {
        self.config = config
        self.uom = uom
    }
    
    public init(config: LineConfig, entries: [Float], uom: String) {
        self.config = config
        self.entries = entries
        self.uom = uom
    }
    
    public func addEntries(entries: [Float]) {
        self.entries.syncAppend(contentsOf: entries)
    }
    
    public func subChannel(from index: Int, lenght: Int) -> RawPnplChannel {
        RawPnplChannel(config: config, entries: Array(entries[index..<(index + lenght)]), uom: uom)
    }

    public var compoundUom: String {
        if uom == "gauss" {
            return "G"
        } else if uom == "celsius" {
            return "°C."
        } else {
            return uom
        }
    }
}

public extension Array where Element == RawPnplChannel {
    func subChannels(from index: Int, lenght: Int) -> [RawPnplChannel] {
        map { $0.subChannel(from: index, lenght: lenght) }
    }
}

extension Double {
    func round(to decimalPlaces: Int) -> Double {
        let precisionNumber = pow(10, Double(decimalPlaces))
        var n = self
        n = n * precisionNumber
        n.round()
        n = n / precisionNumber
        return n
    }
}

extension Int {
    func roundToClosestMultipleNumber(multiple: Int) -> Int {
        var result: Int = self
        
        if result % multiple != 0 {
            if result < multiple {
                result = multiple
            } else {
                result = (result + 1).roundToClosestMultipleNumber(multiple: multiple)
            }
        }
        
        return result
    }
}

extension Array {
    static func resample<T>(array: [T], toSize newSize: Int) -> [T] {
        let size = array.count
        return (0 ..< newSize).map { array[$0 * size / newSize] }
    }
}
