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

// MARK: - extend the FileHandle to write directy some complex type
extension FileHandle{

    
    /// write a string
    ///
    /// - Parameter val: string to write, it will be econded as utf8 string
    public func writeStr(_ val:String){
        let data = val.data(using: .utf8);
        if let d = data {
            write(d);
        }
    }

    
    /// write a uint32 value
    ///
    /// - Parameter val: value to write, it will be writed with little endianes
    public func writeUInt32(_ val:UInt32){
        var temp = val;
        let data = Data(bytes: &temp, count: 4);
        write(data)
    }

    
    /// write a int16 value
    ///
    /// - Parameter val: value to write, it will be writed as little endian
    public func writeUInt16(_ val:UInt16){
        var temp = val;
        let data = Data(bytes: &temp, count: 2);
        write(data)
    }
}


/// create a wave file and store the audio stream
public class W2STWaveFileDump {

    
    /// date format that will be the file name
    private static let DATE_FORMAT = "yyyyMMdd_HHmmss"
    
    private static let FILE_NAME_FORMAT="%@.wav"

    
    /// location of the created filed
    public let fileLocation:URL;
    
    /// file pointer
    private var outFile:FileHandle;
    
    /// thread used to serialize and put on background the write operation
    private let mWriteQueue=DispatchQueue(label: "WriteWavFile"); //serial queue
    
    /// number of byte writed
    private var mNByteWrite:UInt32=0;

    init?(audioParam: BlueSTSDKAudioCodecSettings){
        fileLocation = W2STWaveFileDump.createFile();
        do {
            outFile = try FileHandle(forWritingTo: fileLocation)
        }catch (_){
            return nil;
        }
        mWriteQueue.async{
            self.writeWavHeader(audioParam);
            self.mNByteWrite=0;
        }
    }

    private static func getFileName()->String{
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = DATE_FORMAT;
        let date = dateFormatter.string(from: Date()) //string from now
        return String(format: FILE_NAME_FORMAT, date);
    }

    private static func getDocumentDirectory() -> URL?{
        let fileManager = FileManager.default;
        let paths = fileManager.urls(for:.documentDirectory, in: .userDomainMask )
        return paths.first;
    }

    private static func createFile() -> URL{
        let fileManager = FileManager.default;
        let docDir = getDocumentDirectory();
        let fileName = W2STWaveFileDump.getFileName();
        let fileUrl = URL(fileURLWithPath: fileName, relativeTo: docDir);
        if(!fileManager.fileExists(atPath: fileUrl.path)){
            fileManager.createFile(atPath: fileUrl.path, contents: nil)
        }

        return fileUrl;
    }

    private func writeWavHeader(_ param: BlueSTSDKAudioCodecSettings){
        outFile.writeStr("RIFF");// chunk id
        outFile.writeUInt32(0);// chunk size
        outFile.writeStr("WAVE");// format
        outFile.writeStr("fmt ");// subchunk 1 id
        outFile.writeUInt32(16);// subchunk 1 size
        outFile.writeUInt16(1);// audio format (1 = PCM)
        outFile.writeUInt16(UInt16(param.channels))// number of channels
        outFile.writeUInt32(UInt32(param.samplingFequency)) // sample rate
        let byteRate = UInt32(param.channels*param.samplingFequency*param.bytesPerSample)
        outFile.writeUInt32(byteRate);// byte rate
        outFile.writeUInt16(UInt16(param.channels*param.bytesPerSample)); // block align
        outFile.writeUInt16(8*UInt16(param.bytesPerSample));// bits per sample
        outFile.writeStr("data");// subchunk 2 id
        outFile.writeUInt32(0);// subchunk 2 size
    }

    public func writeSample(sampleData:Data){
        mWriteQueue.async{
            self.outFile.write(sampleData);
            self.mNByteWrite = self.mNByteWrite + UInt32(sampleData.count);
        }
    }

    public func stopRecord(){
        mWriteQueue.sync{
            self.outFile.seek(toFileOffset: 4)
            self.outFile.writeUInt32(36 + mNByteWrite);
            self.outFile.seek(toFileOffset: 40)
            self.outFile.writeUInt32(mNByteWrite);
            self.outFile.closeFile();
        }//sync
    }

}
