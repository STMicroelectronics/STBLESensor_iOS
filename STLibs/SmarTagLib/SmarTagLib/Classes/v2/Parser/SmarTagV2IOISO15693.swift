//
//  SmartTagV2IOISO15693.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreNFC
import SmarTagLib

@available(iOS 14, *)
public class SmartTagV2IOISO15693: SmarTag2IO {
    
    private let mTag2: NFCISO15693Tag
    
    public init(_ tag2: NFCISO15693Tag){
        self.mTag2 = tag2
    }
    
    /** var id:Data? { get { return mTag2.identifier } } */
    
    private static let LAST_BASE_BLOCK = 255
    private static let BLOCK_SIZE = 4
    private static let MAX_BLOCK_WRITE = 4
    
    public func read(address: Int, onComplete:@escaping (IOResult) -> Void) {
        mTag2.extendedReadSingleBlock(requestFlags: [.address, .highDataRate], blockNumber: address){ data, error in
            if let error = error as? NFCReaderError {
                print(error.localizedDescription)
                onComplete(IOResult.failure(error.toSmarTagIOError))
            }else{
                onComplete(IOResult.success(data))
            }
            
        }
    }
      
    public func readExtended(range: Range<Int>, onComplete:@escaping (IOResult) -> Void) {
        //print("ext read: \(range.lowerBound) -> \(range.upperBound)")
        var finalData = Data(capacity: range.count*SmartTagV2IOISO15693.BLOCK_SIZE)
        func internalRead(range:Range<Int>){
            self.mTag2.extendedReadSingleBlock(requestFlags: [.address,.highDataRate], blockNumber: range.lowerBound){ data, error in
                if let error = error as? NFCReaderError {
               print(error)
               print(error.localizedDescription)
               onComplete(IOResult.failure(error.toSmarTagIOError))
            }else{
                finalData.append(data)
                if(range.count == 1) {
                    onComplete(Result.success(finalData))
                }else{
                    internalRead(range:range.dropFirst())
                }//if last
            }//if error
            }//readSingleBlock
            
        }
            
        internalRead(range: range)
    }
    
    public func read(range: Range<Int>, onComplete: @escaping (IOResult) -> Void) {
        //print("ext read: \(range.lowerBound) -> \(range.upperBound)")
        var finalData = Data(capacity: range.count*SmartTagV2IOISO15693.BLOCK_SIZE)
        func internalRead(range:Range<Int>){
            self.mTag2.extendedReadSingleBlock(requestFlags: [.address,.highDataRate], blockNumber: range.lowerBound){ data, error in
                if let error = error as? NFCReaderError {
               print(error)
               print(error.localizedDescription)
               onComplete(IOResult.failure(error.toSmarTagIOError))
            }else{
                finalData.append(data)
                if(range.count == 1) {
                    onComplete(Result.success(finalData))
                }else{
                    internalRead(range:range.dropFirst())
                }//if last
            }//if error
            }//readSingleBlock
            
        }
            
        internalRead(range: range)
    }
    
    public func writeExtendedSingleBlock(startAddress:Int, data:Data, onComplete:@escaping (SmarTagIOError?)->Void) {
        mTag2.extendedWriteSingleBlock(requestFlags: [.address,.highDataRate], blockNumber: startAddress, dataBlock: data) { error in
            if error == nil{
                onComplete(nil)
            }else{
                if let error = error as? NFCReaderError {
                   print(error)
                   print(error.localizedDescription)
                    onComplete(error.toSmarTagIOError)
                }else{
                    fatalError()
                }
            }
        }
    }
}

extension NFCReaderError {
    var toSmarTagIOError : SmarTagIOError{
        switch self.code {
        case .readerTransceiveErrorTagConnectionLost:
            return .lostConnection
        case .readerTransceiveErrorTagResponseError:
            return .tagResponseError
        default:
            return .unknown
        }
    }
}
