//
//  TextualMonitorDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 14/10/2026.
//

import SwiftUI
import STBlueSDK
import STCore

extension [String] {
    mutating func appendAndReduceTo32Samples(_ sample: String) -> String {
        var resultString = ""
        
        //Add the last Sample
        self.append(sample)
        
        //Keep the last 32 sample values
        self = self.suffix(32)
        
        self.reversed().forEach { sampleString in
            resultString += sampleString
        }
        
        return resultString
    }
}

class TextualMonitorViewModel: ObservableObject {
    
    @Published var listOfFeatures: [Feature?] = [nil]
    @Published var selectedFeature: Feature? = nil
    
    @Published var terminalStatus: TerminalStatus = .idle
    
    
    var listOfSamples: [String] = []
    
    @Published var logText: String = ""
    
    var pnpLFeature: Feature? = nil
    var dtmi: FirmwareDtmi? = nil
    var rawPnPLEntries: [RawPnPLStreamEntry] = []
    var selectedGPFeatureFormat:  [BleCharacteristicFormat]? = nil
    
    var firmwareDB: Firmware?
    var pnpLMaxWriteLength: Int = 20
    
    let node: Node
    
    public init(node: Node) {
        self.node = node
    }
    
    func loadFeatures (node: Node) {
        let supportedDemoFeature =  node.characteristics.allFeatures().filter{$0.isDataNotifyFeature}
        supportedDemoFeature.forEach { feature in
            listOfFeatures.append(feature)
        }
        
        if supportedDemoFeature.contains(where: {feature in feature is RawPnPLControlledFeature}) {
            //If we had also the RawPnPLControlled Feature
            
            //Take the DTMI for the running fw
            dtmi = BlueManager.shared.dtmi(for: node)
            
            if dtmi != nil {
                //If we have a dtmi for the firmware... we search also if there is the PnPL Feature
                pnpLFeature = node.characteristics.first(with: PnPLFeature.self)
            }
        }
        
        //Retrieve the Firmware Model from Firmware DB
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog {
            firmwareDB = catalog.v2Firmware(with: node)
        }
        
        if firmwareDB != nil {
            for feature in supportedDemoFeature {
                if feature is GeneralPurposeFeature {
                    //Change the name of the General Purpose feature
                    if let newName =  firmwareDB?.characteristics?.first(where: {$0.uuid == feature.type.uuid.uuidString.lowercased()})?.name {
                        feature.changeName(newName: newName)
                    }
                } else if feature is PnPLFeature {
                    //Search if there is a max write for PnPL feature
                    if  let pnpLMaxWriteLength = firmwareDB?.characteristics?.first(where: { char in char.uuid == feature.type.uuid.uuidString.lowercased()})?.maxWriteLength {
                        if pnpLMaxWriteLength > node.mtu {
                            self.pnpLMaxWriteLength = node.mtu
                        } else {
                            self.pnpLMaxWriteLength = pnpLMaxWriteLength
                        }
                    }
                }
            }
        }
    }
    
    func requestPnpLStatusUpdate() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.status,  maxWriteLength: pnpLMaxWriteLength, to: node)
    }
    
    func switchTerminalStatus() {
        terminalStatus = terminalStatus == .idle ? .printing : .idle
        
        switch terminalStatus {
        case .idle:
            if let feature = selectedFeature {
                BlueManager.shared.disableNotifications(for: node, feature: feature)
                
                if feature is RawPnPLControlledFeature {
                    //We need to disable also the PnPL Feature
                    BlueManager.shared.disableNotifications(for: node, feature: pnpLFeature!)
                }
            }
            break
        case .printing:
            if let feature = selectedFeature {
                
                listOfSamples.removeAll()
                logText = ""
                
                if feature is RawPnPLControlledFeature {
                    //We need to enable also the PnPL Feature
                    BlueManager.shared.enableNotifications(for: node, feature: pnpLFeature!)
                    requestPnpLStatusUpdate()
                }
                
                BlueManager.shared.enableNotifications(for: node, feature: feature)
            }
            
            break
        }
    }
    
    func clearFeatures() {
        listOfFeatures.removeAll()
        listOfFeatures.append(nil)
        
        if terminalStatus == .printing {
            switchTerminalStatus()
        }
        
        unSelectFeature()
        terminalStatus = .idle
    }
    
    func selectFeature(_ feature: Feature) {
        selectedFeature = feature
        
        //check if it's a General Purpose
        if feature is GeneralPurposeFeature {
            //Search if we have a valid notify format
            if let currentGP = firmwareDB?.characteristics?.first(where: {$0.uuid == feature.type.uuid.uuidString.lowercased()})?.formatNotify {
                //We remove the first timestamp section
                selectedGPFeatureFormat = currentGP.filter{ $0.name != "timestamp"}
            }
        }
    }
    
    func unSelectFeature() {
        selectedFeature = nil
    }
    
    
    func updateTerminalText(feature: any STBlueSDK.Feature,sample: (any STBlueSDK.AnyFeatureSample)?) {
        guard let sample = sample else { return }
        
        //Keep only the samples of the selected feature
        if let selectedFeature = selectedFeature {
            if feature.type.uuid != selectedFeature.type.uuid {
                if feature is PnPLFeature {
                    newPnPLSample(with: sample, and: feature)
                } else {
                    return
                }
            } else {
                switch selectedFeature {
                case is GeneralPurposeFeature:
                    updateFeatureValueGP(sample: sample, formats: selectedGPFeatureFormat)
                case is RawPnPLControlledFeature:
                    updateFeatureValueRawPnPLControlled(with: sample, and: feature)
                    
                default:
                    updateFeatureValue(sample:sample.description)
                }
            }
        }
    }
    
    func newPnPLSample(with sample: AnyFeatureSample?, and feature: Feature) {
        if let pnplFeature = feature as? PnPLFeature {
            guard let sample = pnplFeature.sample,
                  let response = sample.data?.response,
                  let device = response.devices.first else { return }
            
            if let featureSelected = selectedFeature {
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
            logText = listOfSamples.appendAndReduceTo32Samples("\(sample?.description ?? "")" + "\n\n")
        
        } else {
            logText = listOfSamples.appendAndReduceTo32Samples("\(sampleDesc)" + "\n\n")
        }
    }
    
    
    
    
    func updateFeatureValue(sample: String?) {
        let sampleDesc = sample ?? ""
        logText = listOfSamples.appendAndReduceTo32Samples(sampleDesc + "\n\n")
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
                logText = listOfSamples.appendAndReduceTo32Samples(descr + "\n\n")
            } else {
                logText = listOfSamples.appendAndReduceTo32Samples("\nGP Not Recognized" + "\n\n")
            }
        } else {
            if let description = sample?.description {
                logText = listOfSamples.appendAndReduceTo32Samples("\(description)" + "\n\n")
            } else {
                logText = listOfSamples.appendAndReduceTo32Samples("\nGP Not Recognized" + "\n\n")
            }
        }
    }
}
