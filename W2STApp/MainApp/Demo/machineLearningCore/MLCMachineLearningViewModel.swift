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
import BlueSTSDK


class MLCMachineLearningViewModel : NSObject {
    
    private let mFeatureType:BlueSTSDKFeature.Type
    private let mMapperCommand:String?
    
    init(featureType:BlueSTSDKFeature.Type ,mapperCommand:String?) {
        mFeatureType = featureType
        mMapperCommand = mapperCommand
        super.init()
    }
    
    var onNewStatusAvailable:(([RegisterStatus])->())? = nil
    private var lastStatus:[RegisterStatus]? {
        didSet{
            if let notifyStatus = self.lastStatus,
                let callback = self.onNewStatusAvailable{
                DispatchQueue.main.async {
                    callback(notifyStatus)
                }
            }
        }
    }
    
    private var mapper:ValueLabelMapper? {
        didSet{
            self.lastStatus = self.lastStatus?.map{ oldRegister in
                let regId = oldRegister.registerId
                let value = oldRegister.value
                return RegisterStatus(registerId: regId, value: value,
                               algorithmName: mapper?.algorithmName(register: regId),
                               label: mapper?.valueName(register: regId, value: value))

            }
        }
    }
    
    private var valueConsole:ValueLabelConsole?
    
    func startListeDataFrom(node:BlueSTSDKNode){
        if let console = node.debugConsole,
            let command = mMapperCommand{
            valueConsole = ValueLabelConsole(command: command,console: console)
            valueConsole?.loadLabel{ [weak self] mapper in
                self?.mapper = mapper
            }
        }
        if let f = node.getFeatureOfType(mFeatureType){
            f.add(self)
            f.read()
            f.enableNotification()
        }
    }
    
    func stopListenDataFrom(node:BlueSTSDKNode){
        if let f = node.getFeatureOfType(mFeatureType){
            f.remove(self)
            f.disableNotification()
        }
    }
}

extension MLCMachineLearningViewModel : BlueSTSDKFeatureDelegate{
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let status = BlueSTSDKFeatureMachineLearningCore.getRegisterStatus(sample)
        let registerStatus = status.enumerated().map{ (arg) -> RegisterStatus in
            let (id, value) = arg
            let regId = UInt8(id)
            return RegisterStatus(registerId: regId, value: value,
                                  algorithmName: mapper?.algorithmName(register: regId),
                                  label: mapper?.valueName(register: regId, value: value))
        }
        self.lastStatus = registerStatus
    }
    
}
