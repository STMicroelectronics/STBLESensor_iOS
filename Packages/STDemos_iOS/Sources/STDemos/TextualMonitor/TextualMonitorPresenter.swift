//
//  TextualMonitorPresenter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
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

final class TextualMonitorPresenter: DemoPresenter<TextualMonitorViewController> {
    var availableFeatures: [Feature] = []
    
    var pnpLFeature: Feature? = nil
    var dtmi: FirmwareDtmi? = nil
    var rawPnPLEntries: [RawPnPLStreamEntry] = []
    
    var textualStatus: TextualStatus = .idle
    
    var firmwareDB: Firmware?
    var pnpLMaxWriteLength: Int = 20
}

// MARK: - TextualMonitorViewControllerDelegate
extension TextualMonitorPresenter: TextualMonitorDelegate {
    
    func requestPnpLStatusUpdate() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.status,  maxWriteLength: pnpLMaxWriteLength, to: self.param.node)
    }
    
    
    func load() {
        demo = .textual
        
        availableFeatures = param.node.characteristics.allFeatures().filter{$0.isDataNotifyFeature}
        
        if availableFeatures.contains(where: {feature in feature is RawPnPLControlledFeature}) {
            //If we had also the RawPnPLControlled Feature
            
            //Take the DTMI for the running fw
            dtmi = BlueManager.shared.dtmi(for: param.node)
            
            if dtmi != nil {
                //If we have a dtmi for the firmware... we search also if there is the PnPL Feature
                pnpLFeature = param.node.characteristics.first(with: PnPLFeature.self)
            }
        }
        
        //Retrieve the Firmware Model from Firmware DB
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog {
            firmwareDB = catalog.v2Firmware(with: param.node)
        }
        
        if firmwareDB != nil {
            
            for feature in availableFeatures {
                if feature is GeneralPurposeFeature {
                    //Change the name of the General Purpose feature
                    if let newName =  firmwareDB?.characteristics?.first(where: {$0.uuid == feature.type.uuid.uuidString.lowercased()})?.name {
                        feature.changeName(newName: newName)
                    }
                } else if feature is PnPLFeature {
                    //Search if there is a max write for PnPL feature
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
        
        view.configureView()
    }
    
    func selectFeature() {
        let actions: [UIAlertAction] = availableFeatures.map { item in
            let itemName = item.name.replacingOccurrences(of: "Feature", with: "")
            return UIAlertAction.genericButton(itemName) { [weak self] _ in
                self?.view.selectedFeature = item
                
                //check if it's a General Purpose
                if item is GeneralPurposeFeature {
                    //Search if we have a valid notify format
                    if let currentGP = self?.firmwareDB?.characteristics?.first(where: {$0.uuid == self?.view.selectedFeature?.type.uuid.uuidString.lowercased()})?.formatNotify {
                        //We remove the first timestamp section
                        self?.view.selectedGPFeatureFormat = currentGP.filter{ $0.name != "timestamp"}
                    }
                }
                self?.view.textualFeatureLabel.text = itemName
                self?.view.logTextView.text = ""
            }
        }
        UIAlertController.presentAlert(from: view, title: nil, actions: actions)
    }
    
    func startStopFeature() {
        if textualStatus == .idle {
            if let feature = view.selectedFeature {
                if feature is RawPnPLControlledFeature {
                    // We need to enable also the PnPL
                    if pnpLFeature != nil {
                        BlueManager.shared.enableNotifications(for: param.node, feature: pnpLFeature!)
                        
                        requestPnpLStatusUpdate()
                    }
                    BlueManager.shared.enableNotifications(for: param.node, feature: feature)
                } else {
                    BlueManager.shared.enableNotifications(for: param.node, feature: feature)
                }
                textualStatus = .listening
                self.view.textualStartStopButton.setImage(self.view.stopImg, for: .normal)
                disableFeatureSelectionInteraction()
            }
        } else {
            enableFeatureSelectionInteraction()
            if let feature = view.selectedFeature {
                BlueManager.shared.disableNotifications(for: param.node, feature: feature)
                
                if feature is RawPnPLControlledFeature {
                    // We need to disable also the PnPL
                    if pnpLFeature != nil {
                        BlueManager.shared.disableNotifications(for: param.node, feature: pnpLFeature!)
                    }
                }
                
                textualStatus = .idle
                self.view.textualStartStopButton.setImage(self.view.playImg, for: .normal)
            }
        }
    }
    
    func stopFeatureAtClose() {
        if textualStatus == .listening {
            if let feature = view.selectedFeature {
                BlueManager.shared.disableNotifications(for: param.node, feature: feature)
                
                if feature is RawPnPLControlledFeature {
                    // We need to disable also the PnPL
                    if pnpLFeature != nil {
                        BlueManager.shared.disableNotifications(for: param.node, feature: pnpLFeature!)
                    }
                }
                
                textualStatus = .idle
            }
        }
    }
    
    func newPnPLSample(with sample: AnyFeatureSample?, and feature: Feature) {
        if let pnplFeature = feature as? PnPLFeature {
            guard let sample = pnplFeature.sample,
                  let response = sample.data?.response,
                  let device = response.devices.first else { return }
            
            if let featureSelected = view.selectedFeature {
                if let rawPnPLControlledFeature = featureSelected as? RawPnPLControlledFeature {
                    rawPnPLControlledFeature.decodePnPLBoardResponseStreams(components: device.components)
                }
            }
        }
    }
    
    func updateFeatureValueRawPnPLControlled(with sample: AnyFeatureSample?, and feature: Feature) {
        Logger.debug(text: feature.description(with: sample))
        var sampleDesc = ""
        
        if let rawPnplFeature = feature as? RawPnPLControlledFeature {
            if let sample = rawPnplFeature.sample {
                rawPnPLEntries = rawPnplFeature.extractBleStreamInfo(sample: sample)
                
                if rawPnPLEntries.isEmpty==false {
                    //All the Entries will have the same StreamID
                    sampleDesc += "StreamID= \(rawPnPLEntries[0].streamId)\n"
                }
                
                for entry in self.rawPnPLEntries {
                    
                    if let enumLabel = entry.value.first as? RawPnPLEnumLabel {
                        sampleDesc += "\(entry.name) [\(enumLabel.label): \(enumLabel.value)] "
                    } else {
                        if entry.channels == 1 {
                            if entry.multiplyFactor != nil {
                                sampleDesc += "\(entry.name) [\(entry.valueFloat)] "
                            } else {
                                sampleDesc += "\(entry.name) [\(entry.value)] "
                            }
                        } else {
                            if entry.multiplyFactor != nil {
                                sampleDesc += "\(entry.name) [\(entry.valueFloat.splitByChunk(entry.channels!))] "
                            } else {
                                sampleDesc += "\(entry.name) [\(entry.value.splitByChunk(entry.channels!))] "
                            }
                        }
                    }
                    if let unit = entry.unit {
                        sampleDesc += "\(unit) "
                    }
                    if let min = entry.min {
                        sampleDesc += "{min = \(min)} "
                    }
                    if let max = entry.max {
                        sampleDesc += "{max = \(max)} "
                    }
                    sampleDesc += "\n"
                }
                
                
            }
        }
        
        if sampleDesc.isEmpty {
            self.view.logTextView.text = "\(sample?.description ?? "")" + "\n\n" + self.view.logTextView.text
        } else {
            self.view.logTextView.text = "\(sampleDesc)" + "\n\n" + self.view.logTextView.text
        }
    }
    
    
    
    
    func updateFeatureValue(sample: String?) {
        let sampleDesc = sample ?? ""
        self.view.logTextView.text = sampleDesc + "\n\n" + self.view.logTextView.text
    }
    
    
    func updateFeatureValueGP(sample: AnyFeatureSample?, formats: [BleCharacteristicFormat]?) {
        
        if let sampleGP = sample as? FeatureSample<GeneralPurposeData>,let formats = formats {
            
            let data = sampleGP.data?.rawData.value
            var offset = 0
            
            var descr = "ts: \(sampleGP.timestamp)"
            
            if let data {
                for format in formats {
                    var value: Float? = nil
                    switch format.type {
                    case .ByteArray:
                        descr += "\n" + "ByteArray not supported.. skip sample"
                    case .Float:
                        value = data.extractFloat(fromOffset: offset)
                    case .Int16:
                        value = Float(data.extractInt16(fromOffset: offset))
                    case .Int32:
                        value = Float(data.extractInt32(fromOffset: offset))
                    case .Int64:
                        descr += "\n" + "Int64 not supported.. skip sample"
                    case .Int8:
                        value = Float(data.extractInt8(fromOffset: offset))
                    case .RawData:
                        descr += "\n" + "RawData not supported.. skip sample"
                    case  .UInt16:
                        value = Float(data.extractUInt16(fromOffset: offset))
                    case .UInt32:
                        value = Float(data.extractUInt32(fromOffset: offset))
                    case .UInt8:
                        value = Float(data.extractUInt8(fromOffset: offset))
                    case .Unit16:
                        value = Float(data.extractUInt16(fromOffset: offset))
                    default:
                        descr += "\n" + "GP Type not recognized"
                    }
                    
                    //if it's a valid value
                    if value != nil {
                        
                        //scale it
                        if let scalefactor = format.scaleFactor {
                            value! *= scalefactor
                        }
                        
                        if let offset = format.offset {
                            value! += offset
                        }
                        
                        descr += "\n" + "\(format.name) = \(value!)"
                        
                        //put unit
                        if let unit = format.unit {
                            descr += " [\(unit)]"
                        }
                        
                        //put min&max range
                        if (format.min != nil) || (format.max != nil) {
                            descr += " <"
                            
                            if let min = format.min {
                                descr += "\(min)"
                            }
                            
                            descr += "..."
                            
                            if let max = format.max {
                                descr += "\(max)"
                            }
                            
                            descr += ">"
                            
                        }
                    }
                    
                    //move to next value
                    if let length = format.length {
                        offset += length
                    }
                }
                self.view.logTextView.text = descr + "\n\n" + self.view.logTextView.text
            } else {
                self.view.logTextView.text = "\nGP Not Recognized" + "\n\n" + self.view.logTextView.text
            }
        } else {
            if let description = sample?.description {
                self.view.logTextView.text = "\(description)" + "\n\n" + self.view.logTextView.text
            } else {
                self.view.logTextView.text = "\nGP Not Recognized" + "\n\n" + self.view.logTextView.text
            }
        }
    }
    
    private func disableFeatureSelectionInteraction() {
        self.view.textualFeatureLabel.isUserInteractionEnabled = false
        self.view.textualFeatureButton.isUserInteractionEnabled = false
        self.view.textualFeatureLabel.layer.opacity = 0.4
        self.view.textualFeatureButton.layer.opacity = 0.4
    }
    
    private func enableFeatureSelectionInteraction() {
        self.view.textualFeatureLabel.isUserInteractionEnabled = true
        self.view.textualFeatureButton.isUserInteractionEnabled = true
        self.view.textualFeatureLabel.layer.opacity = 1.0
        self.view.textualFeatureButton.layer.opacity = 1.0
    }
}

enum TextualStatus {
    case idle
    case listening
}
