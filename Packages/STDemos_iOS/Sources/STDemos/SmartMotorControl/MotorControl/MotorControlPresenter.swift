//
//  MotorControlPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import STCore

final class MotorControlPresenter: DemoPresenter<MotorControlViewController> {
    public var rawPnPLEntries: [RawPnPLStreamEntry] = []
    
    var firmwareDB: Firmware?
    var pnpLMaxWriteLength: Int = 20
}

// MARK: - MotorControlViewControllerDelegate
extension MotorControlPresenter: MotorControlDelegate {

    func load() {
        view.configureView()
        
        //Retrieve the Firmware Model from Firmware DB
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog {
            firmwareDB = catalog.v2Firmware(with: param.node)
        }
        
        demoFeatures = param.node.characteristics.features(with: Demo.smartMotorControl.features)
        
        //Search if there is a max write for PnPL feature
       if firmwareDB != nil {
           for feature in demoFeatures {
               if feature is PnPLFeature {
                   if  let pnpLMaxWriteLength = firmwareDB?.characteristics?.first(where: { char in char.uuid == feature.type.uuid.uuidString.lowercased()})?.maxWriteLength {
                       if pnpLMaxWriteLength > param.node.mtu {
                           self.pnpLMaxWriteLength = param.node.mtu
                       } else {
                           self.pnpLMaxWriteLength = pnpLMaxWriteLength
                       }
                   }
               }
           }
       }
    }

    func sendGetStatusMotorControllerCommand() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.simpleJson(element: "get_status",
                                                                  value: .plain(value: "motor_controller")),
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
    }
    
    func sendStartMotorCommand() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.emptyCommand(element: "motor_controller",
                                                                    param: "start_motor"),
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
    }
    
    func sendStopMotorCommand() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.emptyCommand(element: "motor_controller",
                                                                    param: "stop_motor"),
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
    }
    
    func sendMotorSpeedValue(speed: Int) {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.json(element: "motor_controller",
                                                            param: "motor_speed",
                                                            value: PnpLCommandValue.plain(value: speed)),
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
    }
    
    func sendMotorAckFault() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.emptyCommand(element: "motor_controller",
                                                                    param: "ack_fault"),
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
    }
    
    func newPnPLSample(with sample: AnyFeatureSample?, and feature: Feature) {
        if let pnplFeature = feature as? PnPLFeature {
            
            guard let sample = pnplFeature.sample else { return }
            guard let data = sample.data else { return }
            
            if let rawData = data.rawData {
                if let motorControllerStatusResponse = try? JSONDecoder().decode(MotorControllerStatusResponse.self,
                                                                         from: rawData,
                                                                         keyedBy: "motor_controller") {
                    let motorStatus = motorControllerStatusResponse.motorStatus
                    let motorSpeed = motorControllerStatusResponse.motorSpeed
                    
                    view.motorInformationView.motorSpeedStackView.isHidden = !motorStatus
                    
                    view.setMotorStatus(motorIsRunning: motorStatus)
                    view.setMotorSpeed(motorSpeed: motorSpeed)
                }
            }
          
            if let response = data.response {
                guard let device = response.devices.first else { return }
                if let feature = demoFeatures.first(where: { type(of: $0) == RawPnPLControlledFeature.self }) {
                    if let rawPnPLControlledFeature = feature as? RawPnPLControlledFeature {
                        rawPnPLControlledFeature.decodePnPLBoardResponseStreams(components: device.components)
                    }
                }
            }
        }
    }
    
    func newRawPnPLControlledSample(with sample: AnyFeatureSample?, and feature: Feature) {
        Logger.debug(text: feature.description(with: sample))
        
        let slowTelemetriesView = self.view.slowTelemetriesView
        let motorView = self.view.motorInformationView
        
        if let rawPnplFeature = feature as? RawPnPLControlledFeature {
            if let sample = rawPnplFeature.sample {
                rawPnPLEntries = rawPnplFeature.extractBleStreamInfo(sample: sample)
                slowTelemetriesView.slowTelemetriesStackView.isHidden = false
                setSlowTelemetryValues(in: slowTelemetriesView, andIn: motorView ,with: rawPnPLEntries)
            }
        }
    }
    
    private func setSlowTelemetryValues(in view: SlowMotorTelemetriesView, andIn motorView: MotorInformationView, with rawPnPLEntries: [RawPnPLStreamEntry]) {
        for entry in self.rawPnPLEntries {
            
            switch entry.name {
            case "ref_speed":
                view.speedRefStackView.isHidden = false
                view.speedRefValueLabel.text = "\(entry.value.first!)"
                if let unit = entry.unit {
                    view.speedRefUnitLabel.text = "\(unit)"
                }
            case "speed":
                view.speedMesaureStackView.isHidden = false
                view.speedMeasureValueLabel.text = "\(entry.value.first!)"
                if let unit = entry.unit {
                    view.speedMeasureUnitLabel.text = "\(unit)"
                }
            case "temperature":
                view.tempRowStackView.isHidden = false
                view.tempRowLabel.text = "\(entry.name)"
                view.tempValueLabel.text = "\(entry.value.first!)"
                if let unit = entry.unit {
                    view.tempUnitLabel.text = "\(unit)"
                }
            case "fault":
                if let intValue = Int("\(entry.value.first!)") {
                    let error = MotorControlFault.getErrorCodeFromValue(code: intValue)
                    if error != .none {
                        setFaultView(motorView: motorView, error: error)
                    }
                }
            case "bus_voltage":
                view.busVoltageStackView.isHidden = false
                view.busVoltageValueLabel.text = "\(entry.value.first!)"
                if let unit = entry.unit {
                    view.busVoltageUnitLabel.text = "\(unit)"
                }
            case "probability_neai":
                if let floatValue = entry.value.first as? Float {
                    view.neaiClassValueLabel.text = "\(floatValue.rounded(toPlaces: 1))"
                    view.neaiStackView.isHidden = false
                } else {
                    view.neaiClassValueLabel.text = "\(entry.value.first!)"
                }
                if let unit = entry.unit {
                    view.neaiClassUnitLabel.text = "\(unit)"
                }
            case "class_neai":
                if let enumLabel = entry.value.first as? RawPnPLEnumLabel {
                    view.neaiRowLabel.text = "Class: \(enumLabel.label)"
                }
            default: break
            }
            
        }
    }
    
    private func setFaultView(motorView: MotorInformationView, error: MotorControlFault) {
        self.view.motorFault = error
        
        motorView.motorSpeedStackView.isHidden = false
        
        let stringError = "FAULT: \(error.getErrorStringFromCode())\nA problem has been detected, click on FAULT ACK to restart the motor."
        motorView.motorStatusMessage.text = stringError
        motorView.motorStatusMessage.textColor = ColorLayout.yellow.auto
        
        Buttonlayout.standardYellow.apply(to: motorView.motorButton, text: "FAULT ACK")
        
        motorView.motorStatusLabel.textColor = ColorLayout.yellow.auto
        motorView.motorStatusImage.image = ImageLayout.image(with: "motor_info_warning", in: .module)
    }
}

extension Float {
    func rounded(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
