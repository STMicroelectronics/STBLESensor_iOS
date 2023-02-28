//
//  DataTransporter.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 27/01/21.
//

import Foundation

public class DataTransporter {
    private static let MTU_SIZE: Int = 20
    private static let TP_START_PACKET: UInt8 = 0x00
    private static let TP_START_END_PACKET: UInt8 = 0x20
    private static let TP_MIDDLE_PACKET: UInt8 = 0x40
    private static let TP_END_PACKET: UInt8 = 0x80
    
    private var codedBuffer = Data()
    private let debug = false
    
    public func decapsulate(data: Data) -> Data? {
        
        switch data[0] {
        case Self.TP_START_PACKET:
            codedBuffer.removeAll(keepingCapacity: true)
            codedBuffer.append(data[1...])
            return nil
            
        case Self.TP_START_END_PACKET:
            codedBuffer.removeAll(keepingCapacity: true)
            codedBuffer.append(data[1...])
            return codedBuffer
            
        case Self.TP_MIDDLE_PACKET:
            codedBuffer.append(data[1...])
            return nil
            
        case Self.TP_END_PACKET:
            codedBuffer.append(data[1...])
            return codedBuffer
            
        default:
            return nil
        }
    }

    public func encapsulate(string: String?) -> Data {
        guard let byteCommand = string?.data(using: .utf8) else { return Data() }

        var head = Self.TP_START_PACKET
        var data = Data()
        let mtuSize = Self.MTU_SIZE
        var count = 0
        let codedDataLength = byteCommand.count
        let codedDataLengthBytes = Data(bytes: Int16(codedDataLength).reversedBytes, count: Int16(codedDataLength).reversedBytes.count)
        
        while count < codedDataLength {
            var size = min(Int(mtuSize) - 1, codedDataLength - count)
            if codedDataLength - count <= mtuSize - 1 {
                if count == 0 {
                    if codedDataLength - count <= mtuSize - 3 {
                        head = Self.TP_START_END_PACKET
                    } else {
                        head = Self.TP_START_PACKET
                    }
                } else {
                    head = Self.TP_END_PACKET
                }
            }
            
            switch head {
                case Self.TP_START_PACKET:
                    let to = (mtuSize - 3) - 1
                    data.append(head)
                    data.append(codedDataLengthBytes)
                    data.append(byteCommand[0...to])
                    size = Int(mtuSize - 3)
                    head = Self.TP_MIDDLE_PACKET
                    
                    if debug {
                        debugPrint("set data from 0 to \(to), size: \(size) -> \(byteCommand[0...to])")
                    }
                    
                case Self.TP_START_END_PACKET:
                    data.append(head)
                    data.append(codedDataLengthBytes)
                    data.append(byteCommand[0...(codedDataLength - 1)])
                    size = codedDataLength
                    head = Self.TP_START_PACKET
                    
                    if debug {
                        debugPrint("set data from 0 to \(codedDataLength), size: \(size) -> \(byteCommand[0...codedDataLength])")
                    }
                    
                case Self.TP_MIDDLE_PACKET:
                    let to = (count + (mtuSize - 1)) - 1
                    
                    data.append(head)
                    data.append(byteCommand[count...to])
                    
                    if debug {
                        debugPrint("set data from \(count) to \( to ), size: \(size) -> \(byteCommand[count...to])")
                    }
                    
                case Self.TP_END_PACKET:
                    data.append(head)
                    data.append(byteCommand[count...])
                    head = Self.TP_START_PACKET
                    
                    if debug {
                        debugPrint("set data from \(count) to END, size: \(size) -> \(byteCommand[count...])")
                    }
                    
                default:
                    break
            }
            
            count += size
        }

        if debug {
            debugPrint("result: \(String(data: data, encoding: .ascii))")
            debugPrint("Result hex: \(data.hex)")
        }
        
        return data
    }
}
