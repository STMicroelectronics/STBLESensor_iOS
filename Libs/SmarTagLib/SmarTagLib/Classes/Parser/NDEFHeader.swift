/*
* Copyright (c) 2019  STMicroelectronics – All rights reserved
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

internal struct NDefRecordHeader{
    let tnf:UInt8
    let idLength:UInt8
    let typeLength:UInt8
    let payloadLength:UInt32
    
    //tag type is the last 3 bit
    var type:UInt8 {
        return tnf & 0x07
    }
    
    var isShortRecord:Bool{
        return tnf.isShortRecord
    }
    
    var hasIdLength:Bool{
        return tnf.hasIdLength
    }
    
    var length:UInt16{
        return ( isShortRecord ? 3 : 6) + ( hasIdLength ? 1 : 0)
    }
    
    var isLastRecord:Bool{
        return tnf & 0x40 != 0
    }
    
}

fileprivate extension UInt8 {
    
    var isShortRecord:Bool{
        return (self & 0x10) != 0
    }
    
    var hasIdLength:Bool{
        return (self & 0x08) != 0
    }
}

fileprivate extension Data{
    var toBEUInt32:UInt32{
        let  reverseData:[UInt8] = self.reversed()
        return Data(reverseData).withUnsafeBytes{ $0.load(as: UInt32.self)}
    }
}

internal extension SmarTagIO {
    
    func readNDefRecordFromOffset( offset:Int, onComplete: @escaping (Result<NDefRecordHeader,SmarTagIOError>)->()){
        read(range: offset..<offset+2){ result in
            print("readNDefRecordFromOffset",result)
            switch(result){
            case .failure(let error):
                onComplete(Result.failure(error))
                return
            case .success( let rawHeader):
                let payloadLengthSize = rawHeader[0].isShortRecord ? 1 : 4
                let payloadLength = rawHeader[0].isShortRecord ? UInt32(rawHeader[2]) : rawHeader[2..<6].toBEUInt32
                let idLength = rawHeader[0].hasIdLength ? rawHeader[2 + payloadLengthSize] : 0
                let ndefHeader = NDefRecordHeader(tnf: rawHeader[0],
                                                  idLength: idLength,
                                                  typeLength: rawHeader[1],
                                                  payloadLength: payloadLength)
                onComplete(Result.success(ndefHeader))
            
            }//switch
        }//read
    }
    
}

/*
fun SmarTagIO.getNDefRecordFromOffset(offset:Short): NDefRecordHeader {
    val headerPart1 = read(offset)
    val headerPart2 = read(offset.inc())
    val header = headerPart1+headerPart2

    val payloadLength:Long = if (isShortRecord(header[0])){
        header[2].toLong()
    }else{
        header.extractBEUIntFrom(2)
    }
    val payloadLengthSize= if (isShortRecord(header[0])){
        1
    }else{
        4
    }
    val idLength:Byte = if (hasIdLength(header[0])){
        header[2+payloadLengthSize]
    }else {
        0
    }
    return NDefRecordHeader(
            tnf = header[0],
            idLength = idLength,
            typeLength = header[1],
            payloadLength = payloadLength
    )


}

 fun SmarTagIO.readStringFromByteOffset(byteOffset:Short, length:Short):String{
     //we can read 4 byte at the time
     val startCellOffset = byteOffset.rem(4)
     val startRead = ((byteOffset-startCellOffset)/4).toShort()
     val endRead = (startRead + length.div(4) + 1).toShort() // +1 if the value is not multiple of 4

     val finalString = StringBuffer()

     (startRead..endRead).forEach { i ->
         val byteString = read(i.toShort())
         byteString.forEach { finalString.append(it.toChar()) }
     }
     return finalString.substring(startCellOffset,startCellOffset+length)

 }




 */
