//
//  HighSpeedDataLogConfigurationViewController+LoadConfig.swift
//  W2STApp
//
//  Created by Dimitri Giani on 28/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

extension HighSpeedDataLogConfigurationViewController {
    internal func applyTryToApplyConfiguration(_ data: Data) {
        if let sensors = try? JSONDecoder().decode([HSDSensor].self, from: data) {
            sensors.forEach { sensor in
                if let currentSensor = model?.sensorWithId(sensor.id) {
                    if !currentSensor.statusIsEqual(sensor) {
                        let command = sensorChangesCommand(id: sensor.id, currentSensor: currentSensor, newSensor: sensor)
                        feature?.sendSetCommand(command) {}
                    }
                }
            }
            
            model?.sensor = sensors
            updateUI()
        }
    }

    internal func sensorChangesCommand(id: Int, currentSensor: HSDSensor, newSensor: HSDSensor) -> HSDSetSensorCmd {
        var changes: [SubSensorStatusParam] = []
        newSensor.sensorDescriptor.subSensorDescriptor.forEach { subSensor in
            if let currentStatus = currentSensor.getStatusForDescriptor(subSensor),
               let newStatus = newSensor.getStatusForDescriptor(subSensor) {
                if currentStatus != newStatus {
                    changes.append(contentsOf: sensorStatusChanges(id: subSensor.id, currentStatus: currentStatus, newStatus: newStatus))
                }
            }
        }
        return HSDSetSensorCmd(sensorId: id, subSensorStatus: changes)
    }

    internal func sensorStatusChanges(id: Int, currentStatus: HSDSensorStatus, newStatus: HSDSensorStatus) -> [SubSensorStatusParam] {
        var diff: [SubSensorStatusParam] = []
        
        if newStatus.isActive != currentStatus.isActive {
            diff.append(IsActiveParam(id: id, isActive: newStatus.isActive))
        }
        if let odr = newStatus.ODR, newStatus.ODR != currentStatus.ODR {
            diff.append(ODRParam(id: id, odr: odr))
        }
        if let fs = newStatus.FS, newStatus.FS != currentStatus.FS {
            diff.append(FSParam(id: id, fs: fs))
        }
        let ts = newStatus.samplesPerTs
        if ts != currentStatus.samplesPerTs {
            diff.append(SamplePerTSParam(id: id, samplesPerTs: ts))
        }
        
        /**
         Check MLC UFC Status. The cases are:
         
         1. Load UCF false | Board UCF true => set to false OK
         2. Load UCF false | Baord UCF false => set to false OK
         3. Load UCF true | Board UCF true | sensor has identical parameters to the bord => set to true OK
         4. Load UCF true | Board UCF true | sensor has different parameters to the board => set to false OK
         5. Load UCF true | Board UCF false => set to false OK
         
         Only case #5 is to manage manually
         */
        if !currentStatus.ucfLoaded && newStatus.ucfLoaded {
            newStatus.ucfLoaded = false
        }
        
        return diff
    }
}
