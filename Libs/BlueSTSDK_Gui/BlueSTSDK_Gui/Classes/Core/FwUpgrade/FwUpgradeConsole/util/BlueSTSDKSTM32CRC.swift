/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
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


/// Compute the crc with the same algorithm/polynomial used inside the STM32.
public class BlueSTSDKSTM32CRC{
    
    private static let INITIAL_VALUE:UInt32 = 0xffffffff;
    private static let CRC_TABLE:[UInt32] = [ // Nibble lookup table for 0x04C11DB7 polynomial
    0x00000000, 0x04C11DB7, 0x09823B6E, 0x0D4326D9, 0x130476DC, 0x17C56B6B, 0x1A864DB2, 0x1E475005,
    0x2608EDB8, 0x22C9F00F, 0x2F8AD6D6, 0x2B4BCB61, 0x350C9B64, 0x31CD86D3, 0x3C8EA00A, 0x384FBDBD];
    
    public var crcValue:UInt32=INITIAL_VALUE;
    
    private static func crc32fast(_ crc:UInt32,_ newData:UInt32)->UInt32 {
        var newCrc = crc ^ newData; // Apply all 32-bits
    
        // Process 32-bits, 4 at a time, or 8 rounds
        
         // Assumes 32-bit reg, masking index to 4-bits
        newCrc = (newCrc << 4) ^ BlueSTSDKSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTSDKSTM32CRC.CRC_TABLE[Int(newCrc >> 28)]; //  0x04C11DB7 Polynomial used in STM32
        newCrc = (newCrc << 4) ^ BlueSTSDKSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTSDKSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTSDKSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTSDKSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTSDKSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTSDKSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
    
        return newCrc;
    }
    
    
    /// update the CRC value with the new data
    /// Node: we use world of 4 bytes to compute the crc, if the sequence has a length
    /// that is not a multiple of 4 bytes the last bytes will be ingored.
    /// - Parameter data: new bytes to add at the crc computation
    public func upgrade(_ data:Data){
        data.withUnsafeBytes{ (ptr:UnsafeRawBufferPointer) in
            let uint32Ptr = ptr.bindMemory(to: UInt32.self)
            uint32Ptr.forEach{
                crcValue = BlueSTSDKSTM32CRC.crc32fast(crcValue, $0)
            }
        }
    }
    
    /// reset the crc value to the initial value
    public func reset(){
        crcValue = BlueSTSDKSTM32CRC.INITIAL_VALUE;
    }
    
    /// utility function to compute the crc of a specific data
    ///
    /// - Parameter data: sequence of byte used for computing the crc
    /// - Returns: crc for the data sequence
    public static func getCrc(_ data:Data)->UInt32{
        let length = data.count - data.count % 4
        let tempData = data[0..<length]
        let crcEngine = BlueSTSDKSTM32CRC()
        crcEngine.upgrade(tempData)
        return crcEngine.crcValue
    }
}
