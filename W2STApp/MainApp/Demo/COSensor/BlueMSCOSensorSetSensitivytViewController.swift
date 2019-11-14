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

//extend NSObject to be able to implement BlueSTSDKCOSensorFeatureDelegate
class BlueMSCOSensorSetSensitivityController : NSObject{

    private static let SET_SENSITIVYT_TITLE = {
        return  NSLocalizedString("Set Sensitivity",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCOSensorSetSensitivityController.self),
                                  value: "Set Sensitivity",
                                  comment: "Set Sensitivity");
    }();

    private static let SET_SENSITIVYT_MESSAGE = {
        return  NSLocalizedString("Insert the new sensitivity",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCOSensorSetSensitivityController.self),
                                  value: "Insert the new sensitivity",
                                  comment: "Insert the new sensitivity");
    }();
    
    private static let SAVE_ACTION = {
        return  NSLocalizedString("Save",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCOSensorSetSensitivityController.self),
                                  value: "Save",
                                  comment: "Save");
    }();
    
    let dialog:UIAlertController
    private let coSensor:BlueSTSDKFeatureCOSensor
    
    init(sensor:BlueSTSDKFeatureCOSensor){
        
        dialog = UIAlertController(
            title: BlueMSCOSensorSetSensitivityController.SET_SENSITIVYT_TITLE,
            message: BlueMSCOSensorSetSensitivityController.SET_SENSITIVYT_MESSAGE,
            preferredStyle: .alert)
        
        coSensor = sensor;
        super.init()
        
        initializeDialogView()
        
        coSensor.add(self)
        coSensor.requestSensitivity()
    }
    
    private func initializeDialogView(){
        dialog.addTextField{ textField in
            textField.keyboardType = .decimalPad
            textField.keyboardAppearance = .alert
            textField.returnKeyType = .done
        }
        dialog.addAction(UIAlertAction(title: BlueMSCOSensorSetSensitivityController.SAVE_ACTION,
                                       style: .default){ _ in
            if let newValue = self.getNewSensitivytValue(){
                self.coSensor.setSensorSensitivity(newValue)
            }
            self.dismissDialog()
        })
    }
    
    private func dismissDialog(){
        // remove the listener in the case the sensitivity read did not arrived
        coSensor.remove(self)
        dialog.dismiss(animated: true, completion: nil)
    }
    
    private func getNewSensitivytValue() -> Float?{
        let strValue = dialog.textFields?.first?.text
        if let value = strValue{
            return Float(value)
        }
        return nil
    }
    
    fileprivate func setSensitivytValue(_ value:Float){
        dialog.textFields?.first?.text = String(format: "%f", value)
    }
    
}

extension BlueMSCOSensorSetSensitivityController : BlueSTSDKCOSensorFeatureDelegate{
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
    }
    
    public func didUpdate(_ feature: BlueSTSDKFeatureCOSensor, sensitivity: Float) {
        coSensor.remove(self)
        DispatchQueue.main.async {
            self.setSensitivytValue(sensitivity)
        }
    }
}

