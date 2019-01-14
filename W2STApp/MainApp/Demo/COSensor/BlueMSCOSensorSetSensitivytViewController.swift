//
//  BlueMSCOSensorSetSensitivytViewController.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 23/08/2018.
//  Copyright © 2018 STMicroelectronics. All rights reserved.
//

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

