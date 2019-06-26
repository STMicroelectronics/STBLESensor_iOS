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
import BlueSTSDK

public class NucleoConsole{
    private static let MAX_NAME_LENGTH = 7;
    private static let SET_NAME_COMMAND_FORMAT = "setName %@\n";
    
    private static let SET_TIME_FORMAT: DateFormatter = {
        let timeFormat = DateFormatter();
        timeFormat.dateFormat = "HH:mm:ss";
        return timeFormat;
    }();
    private static let SET_TIME_COMMAND_FORMAT = "setTime %@\n";
    
    private static let SET_DATE_FORMAT: DateFormatter = {
        let timeFormat = DateFormatter()
        //set tle locate to uk to be secure to have the the first day of the moth = monday
        timeFormat.locale = Locale(identifier:"en_UK") // to be secure to have the the first day of the moth = monday
        timeFormat.dateFormat = "ee/dd/MM/yy";
        return timeFormat;
    }();
    private static let SET_DATE_COMMAND_FORMAT = "setDate %@\n";

    
    private let mConsole:BlueSTSDKDebug;
    
    public init(_ console:BlueSTSDKDebug){
        mConsole = console;
    }
    
    public func setName(newName:String){
        guard !newName.isEmpty else{
            return;
        }
        let namePrefix = newName.prefix(NucleoConsole.MAX_NAME_LENGTH);
        mConsole.writeWithoutQueue(String(format: NucleoConsole.SET_NAME_COMMAND_FORMAT, String(namePrefix)));
    }
 
    public func setTime(date:Date){
        let timeStr = NucleoConsole.SET_TIME_FORMAT.string(from: date);
        mConsole.writeWithoutQueue(String(format:NucleoConsole.SET_TIME_COMMAND_FORMAT,timeStr));
    }
    
    public func setDate(date:Date){
        let timeStr = NucleoConsole.SET_DATE_FORMAT.string(from: date);
        mConsole.writeWithoutQueue(String(format:NucleoConsole.SET_DATE_COMMAND_FORMAT,timeStr));
    }
 
    public func setDateAndTime(date:Date){
        setDate(date: date);
        setTime(date: date);
    }
    
}
