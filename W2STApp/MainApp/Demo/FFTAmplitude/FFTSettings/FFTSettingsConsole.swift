/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
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

class FFTSettingsConsole {
 
    static let ODR_VALUES:[UInt16] = [13,26,52,104,208,416,833,1660]
    static let SIZE_VALUES:[UInt16] = [256,512,1024]
    static let FULL_SCALE_VALUES:[UInt8] = [2,4,8,16]
    static let SUB_RANGE:[UInt8] = [8,16,32,64]
    static let OVERLAP_RANGE = 5...95
    static let ACQUISITION_TIME_RANGE = 500...60000
    
    private static let READ_COMMAND = "getVibrParam"
    private static let WRITE_COMMAND = "setVibrParam "
    private static let SET_ODR_FORMAT = WRITE_COMMAND + "-odr %d\r\n"
    private static let SET_FULLSCALE_FREQ_FORMAT = WRITE_COMMAND + "-fs %d\r\n"
    private static let SET_SIZE_FORMAT = WRITE_COMMAND + "-size %d\r\n"
    private static let SET_WINDOW_FORMAT = WRITE_COMMAND + "-wind %d\r\n"
    private static let SET_ACQUISITION_TIME_FORMAT = WRITE_COMMAND + "-tacq %d\r\n"
    private static let SET_SUBRANGE_FORMAT = WRITE_COMMAND + "-subrng %d\r\n"
    private static let SET_OVERLAP_FORMAT = WRITE_COMMAND + "-ovl %d\r\n"
    private static let SET_ALL_FORMAT = WRITE_COMMAND+" -odr %d -fs %d -size %d -wind %d -tacq %d -subrng %d -ovl %d\r\n"
 
   
    private static let SET_DONE_RESPONSE = try! NSRegularExpression(pattern:".*OK.*")
    fileprivate static let COMMAND_TIMEOUT_MS = TimeInterval(2.0)
    
    private let mConsole:BlueSTSDKDebug
    
    init(console:BlueSTSDKDebug) {
        mConsole = console
    }
 
    func readSettings(onRead callback: @escaping (FFTSettings?)->Void){
        let readerDelegate = FFTSettingsReadListener(console: mConsole,onRead: callback)
        mConsole.add(readerDelegate)
        mConsole.writeMessage(FFTSettingsConsole.READ_COMMAND)
    }
    
    func setWindowType(_ newWindow:FFTSettings.WindowType ){
        let cmd = String(format:FFTSettingsConsole.SET_WINDOW_FORMAT,newWindow.rawValue)
        mConsole.writeWithoutQueue(cmd);
    }
    
    func setOdr( _ newOdr:UInt16){
        let cmd = String(format:FFTSettingsConsole.SET_ODR_FORMAT,newOdr)
        mConsole.writeWithoutQueue(cmd);
    }
    
    func setFFTSize( _ newSize:UInt16){
        let cmd = String(format:FFTSettingsConsole.SET_SIZE_FORMAT,newSize)
        mConsole.writeWithoutQueue(cmd);
    }
    
    func setSensorFullScale( _ newFullScale:UInt8){
        let cmd = String(format:FFTSettingsConsole.SET_FULLSCALE_FREQ_FORMAT,newFullScale)
        mConsole.writeWithoutQueue(cmd);
    }
    
    func setSubRange( _ newSubRange:UInt8){
        let cmd = String(format:FFTSettingsConsole.SET_SUBRANGE_FORMAT,newSubRange)
        mConsole.writeWithoutQueue(cmd);
    }
    
    func setAcquisitionTimeSec( _ newTime:UInt32){
        let cmd = String(format:FFTSettingsConsole.SET_ACQUISITION_TIME_FORMAT,newTime)
        mConsole.writeWithoutQueue(cmd);
    }
    
    func setOverlap( _ newOverlap:UInt8){
        let cmd = String(format:FFTSettingsConsole.SET_OVERLAP_FORMAT,newOverlap)
        mConsole.writeWithoutQueue(cmd);
    }
}



fileprivate class FFTSettingsReadListener : BlueSTSDKDebugOutputDelegate{
    
    private static let EXTRACT_ODR = try! NSRegularExpression(pattern:".*FifoOdr\\s*=\\s*(\\d+)")
    private static let EXTRACT_FULLSCALE = try! NSRegularExpression(pattern:".*fs\\s*=\\s*(\\d+)")
    private static let EXTRACT_WINDOWTYPE = try! NSRegularExpression(pattern:".*wind\\s*=\\s*(\\d+)")
    private static let EXTRACT_SIZE = try! NSRegularExpression(pattern:".*size\\s*=\\s*(\\d+)")
    private static let EXTRACT_ACQUSITION_TIME = try! NSRegularExpression(pattern:".*tacq\\s*=\\s*(\\d+)")
    private static let EXTRACT_SUBRANGE = try! NSRegularExpression(pattern:".*subrng\\s*=\\s*(\\d+)")
    private static let EXTRACT_OVERLAP = try! NSRegularExpression(pattern:".*ovl\\s*=\\s*(\\d+).*")
    
    private var mConsole:BlueSTSDKDebug
    private var mBuffer:String="";
    
    private var mOnReadCallback: (FFTSettings?)->Void
    
    private let mMessageSerializer:DispatchQueue
    private var mCurrentTimeOut:DispatchWorkItem? = nil

    private func removeTimer(){
        mCurrentTimeOut?.cancel()
    }
    
    private func setUpTimer(){
        mCurrentTimeOut = DispatchWorkItem{
            self.notifySettingsRead(settings: nil)
        }
        mMessageSerializer.asyncAfter(deadline: .now()+FFTSettingsConsole.COMMAND_TIMEOUT_MS, execute: mCurrentTimeOut!)
    }
    
    private func notifySettingsRead(settings:FFTSettings?){
        removeTimer()
        mConsole.remove(self)
        mOnReadCallback(settings)
    }
    
    init(console:BlueSTSDKDebug,onRead:@escaping (FFTSettings?)->Void) {
        mConsole = console
        mOnReadCallback = onRead
        mMessageSerializer = DispatchQueue(label: "FFTSettingsReadListener")
    }
    
    private func buildFFTSettingsFromString(_ str:String )->FFTSettings?{
        if let odr = FFTSettingsReadListener.EXTRACT_ODR.extranctIntFromString(str),
           let fullScale = FFTSettingsReadListener.EXTRACT_FULLSCALE.extranctIntFromString(str),
           let rawWinType = FFTSettingsReadListener.EXTRACT_WINDOWTYPE.extranctIntFromString(str),
           let winType = FFTSettings.WindowType(rawValue:UInt8(rawWinType)),
           let size = FFTSettingsReadListener.EXTRACT_SIZE.extranctIntFromString(str),
           let acquisitionTime = FFTSettingsReadListener.EXTRACT_ACQUSITION_TIME.extranctIntFromString(str),
           let overlap = FFTSettingsReadListener.EXTRACT_OVERLAP.extranctIntFromString(str){
                let subRange = FFTSettingsReadListener.EXTRACT_SUBRANGE.extranctIntFromString(str)
                return FFTSettings(winType: winType,
                               odr: UInt16(odr),
                               fullScale: UInt8(fullScale),
                               size: UInt16(size),
                               acqusitionTime_s: UInt32(acquisitionTime),
                               subRange: UInt8(subRange ?? 1),
                               overlap: UInt8(overlap))
        }else {
            return nil
        }
    }
    
    
    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        removeTimer()
        mBuffer += msg
        NSLog("add:%@\nread: %@",msg,mBuffer)
        if let settings = buildFFTSettingsFromString(mBuffer){
            notifySettingsRead(settings: settings)
        }else{
            setUpTimer()
        }
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {
        
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        setUpTimer()
    }

}

fileprivate extension NSRegularExpression{
    func extranctIntFromString(_ str:String)->Int?{
        //convert the string to nsstring since String.count != nsString.lenght, if the strings contains
        // char as \r\n, that in swit are a single character, so the range for match can not include the last chars
        //we can use str.utf16? what we can use for the substring?
        let nsStr = str as NSString
        let matches =  self.matches(in: str, options: [], range: NSMakeRange(0, nsStr.length))
        guard matches.count > 0 else{
            return nil
        }
        let strNumberRange = matches[0].range(at: 1)
        let strNumber = nsStr.substring(with: strNumberRange)
        return Int(strNumber)
    }
}
