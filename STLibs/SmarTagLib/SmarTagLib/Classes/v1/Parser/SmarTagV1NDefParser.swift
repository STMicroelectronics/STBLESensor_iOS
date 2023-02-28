 /*
  * Copyright (c) 2018  STMicroelectronics – All rights reserved
  * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * - Redistributions of source code must retain the above copyright notice, this list of conditions
  * and the following disclaimer.
  *
  * - Redistributions in binary form must reproduce the above copyright notice, this list of
  * conditions and the following disclaimer in the documentation and/or other materials provided
  * with the distribution.
  *
  * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
  * STMicroelectronics company nor the names of its contributors may be used to endorse or
  * promote products derived from this software without specific prior written permission.
  *
  * - All of the icons, pictures, logos and other images that are provided with the source code
  * in a directory whose title begins with st_images may only be used for internal purposes and
  * shall not be redistributed to any third party or modified in any way.
  *
  * - Any redistributions in binary form shall not include the capability to display any of the
  * icons, pictures, logos and other images that are provided with the source code in a directory
  * whose title begins with st_images.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  * OF SUCH DAMAGE.
  */
 
import Foundation
import AssetTrackingDataModel

public class SmarTagV1NDefParser {
    
    private static func getMaxNumOfSample(memory:TagMemoryLayout)->UInt16{
        return (memory.availableSpace-UInt16(SmarTagV1NDefParser.SAMPLE_FIRST_DATA_OFFSET))/8
    }
        
    private static func getSampleDataRange(sampleIndex:Int) -> Range<Int>{
        let start =  SAMPLE_FIRST_DATA_OFFSET+sampleIndex*8
        let end = start + 8
        return start..<end
    }
    
    private let rawData:Data
    private let id:Data?
    
    public init(identifier:Data, rawData:Data){
        self.rawData = rawData
        self.id = identifier.isEmpty ? nil : identifier
    }
    
   public func readContent(onReadComplete:@escaping (Result<SmarTagData,SmarTagIOError>)->()){
        guard rawData[0]==1 else {
            onReadComplete(.failure(.wrongProtocolVersion))
            return
        }
        let version = SmarTagV1Parser.buildVersion(rawData: rawData.subdata(in: SmarTagV1NDefParser.VERSION_DATA_RANGE))
        let configuration = SmarTagV1Parser.buildConfig(rawData: rawData.subdata(in: SmarTagV1NDefParser.CONFIGURATION_DATA_RANGE))
        let dataExtreme = SmarTagV1Parser.buildTagExtreme(rawData: rawData.subdata(in: SmarTagV1NDefParser.EXTREMES_DATA_RANGE), configuration: configuration)
        let samples = SmarTagV1NDefParser.getSamples(rawData: rawData, tagIdSize: id?.count ?? 0)
        let data = SmarTagData(id: id, version: version, configuration: configuration, samples: samples, dataExtreme: dataExtreme)
        onReadComplete(.success(data))
    }
        
    private static func getSamples(rawData:Data, tagIdSize:Int)->[DataSample]{
        let sampleInfo = SmarTagV1Parser.getAcquiredSampleInfo(rawData: rawData.subdata(in: SmarTagV1NDefParser.SAMPLE_INFO_RANGE))
        guard sampleInfo.nSample != 0 else{
            return []
        }
        let memoryLayout = SmarTagV1NDefParser.getTagMemoryLayout(tagIdSize:tagIdSize, payloadSize: rawData.count)
        let maxNSample = SmarTagV1NDefParser.getMaxNumOfSample(memory: memoryLayout)
        let nextSamplePtr = sampleInfo.nextSampleBlock*4 // *4 since each block is 4 bytes
        // /8 since eache sample needs 8 bytes ( 4 byte timestamp + 4 byte data)
        // -1 since we want the last sample and we have the next sample
        let lastSampleIndex = (nextSamplePtr - UInt16(SmarTagV1NDefParser.SAMPLE_FIRST_DATA_OFFSET) - memoryLayout.headerSize)/8 - 1
        var firstSampleIndex =  sampleInfo.nSample >= maxNSample ? lastSampleIndex + 1 : 0
        var tempSamples:[DataSample] = []
        let sampleRawData = rawData.subdata(in: SmarTagV1NDefParser.SAMPLE_FIRST_DATA_OFFSET..<rawData.count)
        for _ in 0..<sampleInfo.nSample{
            let sample = SmarTagV1Parser.getDataSample(from:sampleRawData, index:Int(firstSampleIndex))
            tempSamples.append(sample)
            firstSampleIndex = ( firstSampleIndex + 1 ) % maxNSample
        }
        return tempSamples
    }
    
    private static let VERSION_DATA_RANGE = 0..<4
    private static let CONFIGURATION_DATA_RANGE = 4..<20
    private static let EXTREMES_DATA_RANGE = 24..<60
    private static let SAMPLING_INTERVAL_OFFEST = 4
    private static let SAMPLE_FIRST_DATA_OFFSET = 64
    private static let SAMPLE_INFO_RANGE = 60..<64
    
   private static func getTagMemoryLayout(tagIdSize:Int, payloadSize:Int)->TagMemoryLayout{
       let tag4k = TagMemoryLayout(totalSize: 0x200, idSize: tagIdSize)
       if(payloadSize<=tag4k.availableSpace){
           return tag4k
       }else{
           //return the 64k configuration
           return TagMemoryLayout(totalSize: 0x2000, idSize: tagIdSize)
       }
   }

}


 
fileprivate struct TagMemoryLayout{
    let headerSize:UInt16
    let totalSize:UInt16
    let availableSpace:UInt16
    
    init(totalSize:UInt16, idSize:Int){
        self.totalSize = totalSize;
        var ccSize = UInt16(4)
        let tlvSize = UInt16(4)
        if(totalSize>512){
            //8 = start extended CC size
            ccSize = 8
        }
        //+1 for the byte that telle us the idSize
        let ndefHeaderSize = UInt16(20 + (idSize>0 ? idSize+1 : 0))
        headerSize = ccSize + tlvSize + ndefHeaderSize
        // -4 for the end tlv
        availableSpace = totalSize - headerSize - 4
    }
}

 fileprivate extension DataSample {
    var timestamp:TimeInterval {
        switch self {
        case .sensor(let data):
            return data.date.timeIntervalSinceReferenceDate
        case .event(let data):
            return data.date.timeIntervalSinceReferenceDate
        }
    }
 }
