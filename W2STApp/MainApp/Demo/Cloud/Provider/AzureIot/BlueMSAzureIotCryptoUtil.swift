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

extension String {

    /// return an encoded string that can be used in a web url
    /// it removes dangerous charater encodig it directly in their hex format
    /// - Returns: equivalent string that can be used in a web url
    func encodeWebSafe()->String{
        //http://stackoverflow.com/questions/8088473/how-do-i-url-encode-a-string
        var returnString = "";
        
        // function to get first utf8 byte of a string -> usefult to convert a
        // single char sring to its utf8 byte rappresentation
        let UTF8Char = { (c:String) in
            return c.utf8.first!;
        }
        
        for character in self.utf8{
           switch character{
               case UTF8Char(" "):
                    returnString.append("+");
                    break;
                case UTF8Char("."),UTF8Char("-"),
                     UTF8Char("_"),UTF8Char("~"),
                     UTF8Char("a")...UTF8Char("z"),
                     UTF8Char("A")...UTF8Char("Z"),
                     UTF8Char("0")...UTF8Char("9"):
                        returnString.append(String(format:"%c", character))
                    break;
                default:
                    returnString.append(String(format:"%%%02X", character))
                    break;
            }//switch
        }//for
        return returnString;
    }//encodeWebSafe
}

extension Data{
    
    /// compute the current buffer sha256 hash with the specific key
    ///
    /// - Parameter key: key used to compute the buffer hmac sha256 hash
    /// - Returns: buffer containing the sha256 hash encoeded with the key parameters
    func getSHA256HMac(key: Data) -> Data {
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH));
        digestData.withUnsafeMutableBytes { (ptr:UnsafeMutablePointer<UInt8>) -> Void in
            let outPtr = UnsafeMutableRawPointer(ptr);
            key.withUnsafeBytes({ (ptr:UnsafePointer<UInt8>) -> Void in
                let keyPtr = UnsafeRawPointer(ptr)
                self.withUnsafeBytes({ (ptr:UnsafePointer<UInt8>) -> Void in
                    let dataPtr = UnsafeRawPointer(ptr)
                    CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyPtr, key.count, dataPtr, self.count, outPtr);
                })// self unsafe byte
            }) //key unsefe byte
        } // out unsafe byte
        return digestData;
    }//getSHA256HMac
}
