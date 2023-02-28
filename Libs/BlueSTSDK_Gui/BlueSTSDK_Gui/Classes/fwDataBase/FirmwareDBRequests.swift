//
//  Remote&LocalDBFirmwareRequest.swift
//  BlueSTSDK

import Foundation
import CoreData

public var firmwaresArrayV1: [Firmware] = []
public var firmwaresArrayV2: [Firmware] = []
public var characteristicsArray: [Characteristic] = []

public var firmwaresArray: [Catalog] = []

protocol Requestable: Decodable {
    static var urlRequest: URLRequest { get }
}

struct Object: Requestable {
    static var urlRequest: URLRequest {
        let url = URL(string: "https://raw.githubusercontent.com/STMicroelectronics/appconfig/main/bluestsdkv2/catalog.json")!
        let request = URLRequest(url: url)
        return request
    }
}

extension URLSession {

    static func performRequest<T: Requestable>(on decodable: T.Type, result: @escaping (Result<RemoteDBResponse, Error>) -> Void) {

        URLSession.shared.dataTask(with: decodable.urlRequest) { (data, response, error) in

            // handle error scenarios... `result(.failure(error))`
            // handle bad response... `result(.failure(responseError))`
            // handle no data... `result(.failure(dataError))`

            guard let data = data else { return }
            do {
                let object = try JSONDecoder().decode(RemoteDBResponse.self, from: data)
                result(.success(object))
            } catch {
                result(.failure(error))
            }

        }.resume()

    }

}

public class FirmwareDBRequests: NSObject {
    
    @objc public func requestDBFirmware(container: NSPersistentContainer!) {
        
        URLSession.performRequest(on: Object.self) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                
                let managedContext = container.viewContext
                let boardFirmwareEntity = NSEntityDescription.entity(forEntityName: "BoardFirmware", in: managedContext)
                let csmg = NSManagedObject(entity: boardFirmwareEntity!, insertInto: managedContext) as! BoardFirmware
                
                DispatchQueue.main.async { [unowned self] in
                    for jsonCommit in response.bluestsdk_v2 {

                        /** Build CHARACTERISTICS*/
                        var characteristicsToPut: [Characteristic] = []
                        
                        jsonCommit.characteristics?.forEach{actualChar in
                            
                            var characteristicFormatNotifyToPut: [CharacteristicFormat] = []
                            
                            if !(actualChar.format_notify==nil){
                                actualChar.format_notify?.forEach{fNotify in
                                    /**create a new Characteristic Format Notify (if exist) and add it to characteristic!*/
                                    characteristicFormatNotifyToPut.append(CharacteristicFormat(length: fNotify.length, name: fNotify.name, unit: fNotify.unit, min: fNotify.min, max: fNotify.max, offset: fNotify.offset, scalefactor: fNotify.scalefactor, type: fNotify.type))
                                }
                            }
                            
                            var characteristicFormatWriteToPut: [CharacteristicFormat] = []
                            
                            if !(actualChar.format_write==nil){
                                actualChar.format_write?.forEach{fWrite in
                                    /**create a new Characteristic Format Write (if exist) and add it to characteristic!*/
                                    characteristicFormatWriteToPut.append(CharacteristicFormat(length: fWrite.length, name: fWrite.name, unit: fWrite.unit, min: fWrite.min, max: fWrite.max, offset: fWrite.offset, scalefactor: fWrite.scalefactor, type: fWrite.type))
                                }
                            }
                            
                            /**create a new CHARACTERISTIC and add it to firmware!*/
                            characteristicsToPut.append(Characteristic(name: actualChar.name, uuid: actualChar.uuid, dtmi_name: actualChar.dtmi_name, description_characteristic: actualChar.description, format_notify: characteristicFormatNotifyToPut, format_write: characteristicFormatWriteToPut))
                            
                        }
                        /** END Building*/
                        
                        /** Build CLOUD APPS*/
                        var cloudAppToPut: [CloudApp] = []

                        if !(jsonCommit.cloud_apps==nil){
                            jsonCommit.cloud_apps!.forEach{actualCloudApp in
                                if !(actualCloudApp.dtmi==nil){
                                    if !(actualCloudApp.name==nil){
                                        if !(actualCloudApp.shareable_link==nil){
                                        cloudAppToPut.append(CloudApp(cloud_description: actualCloudApp.description, dtmi: actualCloudApp.dtmi, name: actualCloudApp.name, shareable_link: actualCloudApp.shareable_link, url: actualCloudApp.url))
                                        }else{
                                            cloudAppToPut.append(CloudApp(cloud_description: actualCloudApp.description, dtmi: actualCloudApp.dtmi, name: actualCloudApp.name, shareable_link: "", url: actualCloudApp.url))
                                        }
                                    }else{
                                        cloudAppToPut.append(CloudApp(cloud_description: "", dtmi: actualCloudApp.dtmi, name: "", shareable_link: "", url: ""))
                                    }
                                }
                            }
                        }
                        /** END Building*/
                        
                        /** Build OPTION_BYTES if exist*/
                        var optBytesToPut: [OptByte] = []
                        
                        jsonCommit.option_bytes?.forEach{actualOptByte in
                            
                            var stringValueToPut: [StringValue] = []
                            var iconValueToPut: [IconValue] = []
                            
                            if !(actualOptByte.string_values==nil){
                                actualOptByte.string_values?.forEach{stringValue in
                                    //create a new STRINGVALUE and add it to OptionBytes !
                                    stringValueToPut.append(StringValue(display_name: stringValue.display_name, value: stringValue.value))
                                }
                            }
                            
                            if !(actualOptByte.icon_values==nil){
                                actualOptByte.icon_values?.forEach{iconValue in
                                    //create a new STRINGVALUE and add it to OptionBytes !
                                    iconValueToPut.append(IconValue(comment: iconValue.comment, icon_code: iconValue.icon_code, value: iconValue.value))
                                }
                            }
                            
                            optBytesToPut.append(OptByte(format: actualOptByte.format, name: actualOptByte.name, type: actualOptByte.type, negative_offset: actualOptByte.negative_offset, scale_factor: actualOptByte.scale_factor, string_values: stringValueToPut, icon_values: iconValueToPut))
                            
                        }
                        /** END Building*/
                        
                        //create a new FIRMWARE and add it to list of FIRMARES!
                        firmwaresArrayV2.append(Firmware(ble_dev_id: jsonCommit.ble_dev_id, ble_fw_id: jsonCommit.ble_fw_id, brd_name: jsonCommit.brd_name, fw_name: jsonCommit.fw_name, fw_version: jsonCommit.fw_version, fota: jsonCommit.fota, partial_fota: jsonCommit.partial_fota, characteristics: characteristicsToPut, cloud_apps: cloudAppToPut, option_bytes: optBytesToPut))
                    }
                    
                    for jsonCommit in response.bluestsdk_v1 {

                        /** Build CHARACTERISTICS*/
                        var characteristicsToPut: [Characteristic] = []
                        
                        jsonCommit.characteristics?.forEach{actualChar in
                            
                            var characteristicFormatNotifyToPut: [CharacteristicFormat] = []
                            
                            if !(actualChar.format_notify==nil){
                                actualChar.format_notify?.forEach{fNotify in
                                    /**create a new Characteristic Format Notify (if exist) and add it to characteristic!*/
                                    characteristicFormatNotifyToPut.append(CharacteristicFormat(length: fNotify.length, name: fNotify.name, unit: fNotify.unit, min: fNotify.min, max: fNotify.max, offset: fNotify.offset, scalefactor: fNotify.scalefactor, type: fNotify.type))
                                }
                            }
                            
                            var characteristicFormatWriteToPut: [CharacteristicFormat] = []
                            
                            if !(actualChar.format_write==nil){
                                actualChar.format_write?.forEach{fWrite in
                                    /**create a new Characteristic Format Write (if exist) and add it to characteristic!*/
                                    characteristicFormatWriteToPut.append(CharacteristicFormat(length: fWrite.length, name: fWrite.name, unit: fWrite.unit, min: fWrite.min, max: fWrite.max, offset: fWrite.offset, scalefactor: fWrite.scalefactor, type: fWrite.type))
                                }
                            }
                            
                            /**create a new CHARACTERISTIC and add it to firmware!*/
                            characteristicsToPut.append(Characteristic(name: actualChar.name, uuid: actualChar.uuid, dtmi_name: actualChar.dtmi_name, description_characteristic: actualChar.description, format_notify: characteristicFormatNotifyToPut, format_write: characteristicFormatWriteToPut))
                            
                        }
                        /** END Building*/
                        
                        /** Build CLOUD APPS*/
                        var cloudAppToPut: [CloudApp] = []

                        if !(jsonCommit.cloud_apps==nil){
                            jsonCommit.cloud_apps!.forEach{actualCloudApp in
                                if !(actualCloudApp.dtmi==nil){
                                    if !(actualCloudApp.name==nil){
                                        if !(actualCloudApp.shareable_link==nil){
                                        cloudAppToPut.append(CloudApp(cloud_description: actualCloudApp.description, dtmi: actualCloudApp.dtmi, name: actualCloudApp.name, shareable_link: actualCloudApp.shareable_link, url: actualCloudApp.url))
                                        }else{
                                            cloudAppToPut.append(CloudApp(cloud_description: actualCloudApp.description, dtmi: actualCloudApp.dtmi, name: actualCloudApp.name, shareable_link: "", url: actualCloudApp.url))
                                        }
                                    }else{
                                        cloudAppToPut.append(CloudApp(cloud_description: "", dtmi: actualCloudApp.dtmi, name: "", shareable_link: "", url: ""))
                                    }
                                }
                            }
                        }
                        /** END Building*/
                        
                        /** Build OPTION_BYTES if exist*/
                        var optBytesToPut: [OptByte] = []
                        
                        jsonCommit.option_bytes?.forEach{actualOptByte in
                            
                            var stringValueToPut: [StringValue] = []
                            var iconValueToPut: [IconValue] = []
                            
                            if !(actualOptByte.string_values==nil){
                                actualOptByte.string_values?.forEach{stringValue in
                                    //create a new STRINGVALUE and add it to OptionBytes !
                                    stringValueToPut.append(StringValue(display_name: stringValue.display_name, value: stringValue.value))
                                }
                            }
                            
                            if !(actualOptByte.icon_values==nil){
                                actualOptByte.icon_values?.forEach{iconValue in
                                    //create a new STRINGVALUE and add it to OptionBytes !
                                    iconValueToPut.append(IconValue(comment: iconValue.comment, icon_code: iconValue.icon_code, value: iconValue.value))
                                }
                            }
                            
                            optBytesToPut.append(OptByte(format: actualOptByte.format, name: actualOptByte.name, type: actualOptByte.type, negative_offset: actualOptByte.negative_offset, scale_factor: actualOptByte.scale_factor, string_values: stringValueToPut, icon_values: iconValueToPut))
                            
                        }
                        /** END Building*/
                        
                        //create a new FIRMWARE and add it to list of FIRMARES!
                        firmwaresArrayV1.append(Firmware(ble_dev_id: jsonCommit.ble_dev_id, ble_fw_id: jsonCommit.ble_fw_id, brd_name: jsonCommit.brd_name, fw_name: jsonCommit.fw_name, fw_version: jsonCommit.fw_version, fota: jsonCommit.fota, partial_fota: jsonCommit.partial_fota, characteristics: characteristicsToPut, cloud_apps: cloudAppToPut, option_bytes: optBytesToPut))
                    }
                    
                    for jsonCommit in response.characteristics{
                        /** Build CHARACTERISTICS*/
                        var characteristicsToPut: [Characteristic] = []
                        
                        var characteristicFormatNotifyToPut: [CharacteristicFormat] = []
                        
                        if !(jsonCommit.format_notify==nil){
                            jsonCommit.format_notify?.forEach{fNotify in
                                /**create a new Characteristic Format Notify (if exist) and add it to characteristic!*/
                                characteristicFormatNotifyToPut.append(CharacteristicFormat(length: fNotify.length, name: fNotify.name, unit: fNotify.unit, min: fNotify.min, max: fNotify.max, offset: fNotify.offset, scalefactor: fNotify.scalefactor, type: fNotify.type))
                            }
                        }
                        
                        var characteristicFormatWriteToPut: [CharacteristicFormat] = []
                        
                        if !(jsonCommit.format_write==nil){
                            jsonCommit.format_write?.forEach{fWrite in
                                /**create a new Characteristic Format Write (if exist) and add it to characteristic!*/
                                characteristicFormatWriteToPut.append(CharacteristicFormat(length: fWrite.length, name: fWrite.name, unit: fWrite.unit, min: fWrite.min, max: fWrite.max, offset: fWrite.offset, scalefactor: fWrite.scalefactor, type: fWrite.type))
                            }
                        }
                        
                        /**create a new CHARACTERISTIC and add it to firmware!*/
                        characteristicsArray.append(Characteristic(name: jsonCommit.name, uuid: jsonCommit.uuid, dtmi_name: jsonCommit.dtmi_name, description_characteristic: jsonCommit.description, format_notify: characteristicFormatNotifyToPut, format_write: characteristicFormatWriteToPut))
                            
                        /** END Building*/
                    }
                    
                    
                    let catalog = Catalog(checksum: response.checksum, date: response.date, version: response.version, bluestsdk_v2: firmwaresArrayV2, bluestsdk_v1: firmwaresArrayV1, characteristics: characteristicsArray)
                    firmwaresArray.append(catalog)
                    let mFirmwares = Firmwares(firmwares: firmwaresArray)
                    csmg.setValue(mFirmwares, forKey: "firmwares")
                
                    //SAVE DB Data
                    if container.viewContext.hasChanges {
                        do {
                            try container.viewContext.save()
                        } catch {
                            print("An error occurred while saving: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    public func createBlueSTSDKFirmware(jsonFirmware: BoardJSONFirmware) -> Firmware{
       
        /** Build CHARACTERISTICS*/
        var characteristicsToPut: [Characteristic] = []
        
        if !(jsonFirmware.characteristics==nil){
            
            jsonFirmware.characteristics?.forEach{actualChar in
                
                var characteristicFormatNotifyToPut: [CharacteristicFormat] = []
                
                if !(actualChar.format_notify==nil){
                    actualChar.format_notify?.forEach{fNotify in
                        /**create a new Characteristic Format Notify (if exist) and add it to characteristic!*/
                        characteristicFormatNotifyToPut.append(CharacteristicFormat(length: fNotify.length, name: fNotify.name, unit: fNotify.unit, min: fNotify.min, max: fNotify.max, offset: fNotify.offset, scalefactor: fNotify.scalefactor, type: fNotify.type))
                    }
                }
                
                var characteristicFormatWriteToPut: [CharacteristicFormat] = []
                
                if !(actualChar.format_write==nil){
                    actualChar.format_write?.forEach{fWrite in
                        /**create a new Characteristic Format Write (if exist) and add it to characteristic!*/
                        characteristicFormatWriteToPut.append(CharacteristicFormat(length: fWrite.length, name: fWrite.name, unit: fWrite.unit, min: fWrite.min, max: fWrite.max, offset: fWrite.offset, scalefactor: fWrite.scalefactor, type: fWrite.type))
                    }
                }
                
                /**create a new CHARACTERISTIC and add it to firmware!*/
                characteristicsToPut.append(Characteristic(name: actualChar.name, uuid: actualChar.uuid, dtmi_name: actualChar.dtmi_name, description_characteristic: actualChar.description, format_notify: characteristicFormatNotifyToPut, format_write: characteristicFormatWriteToPut))
                
            }
        }
        /** END Building*/
            
        /** Build CLOUD APPS*/
        var cloudAppToPut: [CloudApp] = []

        if !(jsonFirmware.cloud_apps==nil){
            jsonFirmware.cloud_apps!.forEach{actualCloudApp in
                if !(actualCloudApp.dtmi==nil){
                    if !(actualCloudApp.name==nil){
                        if !(actualCloudApp.shareable_link==nil){
                        cloudAppToPut.append(CloudApp(cloud_description: actualCloudApp.description, dtmi: actualCloudApp.dtmi, name: actualCloudApp.name, shareable_link: actualCloudApp.shareable_link, url: actualCloudApp.url))
                        }else{
                            cloudAppToPut.append(CloudApp(cloud_description: actualCloudApp.description, dtmi: actualCloudApp.dtmi, name: actualCloudApp.name, shareable_link: "", url: actualCloudApp.url))
                        }
                    }else{
                        cloudAppToPut.append(CloudApp(cloud_description: "", dtmi: actualCloudApp.dtmi, name: "", shareable_link: "", url: ""))
                    }
                }
            }
        }
        /** END Building*/
            
        /** Build OPTION_BYTES if exist*/
        var optBytesToPut: [OptByte] = []
        
        if !(jsonFirmware.option_bytes==nil){
            jsonFirmware.option_bytes?.forEach{actualOptByte in
                
                var stringValueToPut: [StringValue] = []
                var iconValueToPut: [IconValue] = []
                
                if !(actualOptByte.string_values==nil){
                    actualOptByte.string_values?.forEach{stringValue in
                        //create a new STRINGVALUE and add it to OptionBytes !
                        stringValueToPut.append(StringValue(display_name: stringValue.display_name, value: stringValue.value))
                    }
                }
                
                if !(actualOptByte.icon_values==nil){
                    actualOptByte.icon_values?.forEach{iconValue in
                        //create a new STRINGVALUE and add it to OptionBytes !
                        iconValueToPut.append(IconValue(comment: iconValue.comment, icon_code: iconValue.icon_code, value: iconValue.value))
                    }
                }
                
                optBytesToPut.append(OptByte(format: actualOptByte.format, name: actualOptByte.name, type: actualOptByte.type, negative_offset: actualOptByte.negative_offset, scale_factor: actualOptByte.scale_factor, string_values: stringValueToPut, icon_values: iconValueToPut))
                
            }
        }
        /** END Building*/
            
        //create a new FIRMWARE and add it to list of FIRMARES!
        return Firmware(ble_dev_id: jsonFirmware.ble_dev_id, ble_fw_id: jsonFirmware.ble_fw_id, brd_name: jsonFirmware.brd_name, fw_name: jsonFirmware.fw_name, fw_version: jsonFirmware.fw_version, fota: jsonFirmware.fota, partial_fota: jsonFirmware.partial_fota, characteristics: characteristicsToPut, cloud_apps: cloudAppToPut, option_bytes: optBytesToPut)
        
    }

    public func createCharacteristic(jsonCharacteristic: BleJSONCharacteristic) -> Characteristic{
        /** Build CHARACTERISTICS*/
        var characteristicsToPut: [Characteristic] = []
        
        var characteristicFormatNotifyToPut: [CharacteristicFormat] = []
        
        if !(jsonCharacteristic.format_notify==nil){
            jsonCharacteristic.format_notify?.forEach{fNotify in
                /**create a new Characteristic Format Notify (if exist) and add it to characteristic!*/
                characteristicFormatNotifyToPut.append(CharacteristicFormat(length: fNotify.length, name: fNotify.name, unit: fNotify.unit, min: fNotify.min, max: fNotify.max, offset: fNotify.offset, scalefactor: fNotify.scalefactor, type: fNotify.type))
            }
        }
        
        var characteristicFormatWriteToPut: [CharacteristicFormat] = []
        
        if !(jsonCharacteristic.format_write==nil){
            jsonCharacteristic.format_write?.forEach{fWrite in
                /**create a new Characteristic Format Write (if exist) and add it to characteristic!*/
                characteristicFormatWriteToPut.append(CharacteristicFormat(length: fWrite.length, name: fWrite.name, unit: fWrite.unit, min: fWrite.min, max: fWrite.max, offset: fWrite.offset, scalefactor: fWrite.scalefactor, type: fWrite.type))
            }
        }
        
        /**create a new CHARACTERISTIC and add it to firmware!*/
        return Characteristic(name: jsonCharacteristic.name, uuid: jsonCharacteristic.uuid, dtmi_name: jsonCharacteristic.dtmi_name, description_characteristic: jsonCharacteristic.description, format_notify: characteristicFormatNotifyToPut, format_write: characteristicFormatWriteToPut)
        /** END Building*/
    }
    
}
