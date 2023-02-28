//
//  ReadBoardFirmwareDataBase.swift
//  BlueSTSDK_Gui

import Foundation
import CoreData
import BlueSTSDK
import BlueSTSDK_Gui

public class ReadBoardFirmwareDataBase {
    
    /** used in order to retrieve DB Firmwares */
    var container: NSPersistentContainer!
    /** contains firmwares */
    public var catalogFirmwares: Firmwares!
    
    
    public init(){
        container = NSPersistentContainer(name: "BoardFirmware")
        container.loadPersistentStores() { (description, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        loadSavedData()
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /** Function that load firmware informations from Local DB */
    func loadSavedData() {
        
        let managedContext = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BoardFirmware")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            for data in result as! [NSManagedObject] {
                catalogFirmwares = data.value(forKey: "firmwares") as? Firmwares
                if !(catalogFirmwares==nil){
                    //debugPrintDB(firmwares: catalogFirmwares!)
                }
            }
        }catch{
            print("Failed")
        }
        
    }
    
    public func saveNewCustomJsonData(newCustomFw: Firmware) -> Bool {
        var customFwAlreadyExist = false
        
        catalogFirmwares?.firmwares.forEach{ c in
            c.bluestsdk_v2?.forEach{fw in
                if(fw.ble_fw_id == newCustomFw.ble_fw_id && fw.ble_dev_id == newCustomFw.ble_dev_id){
                    customFwAlreadyExist = true
                }
            }
        }
        
        if !(customFwAlreadyExist){
            catalogFirmwares?.firmwares.forEach{ c in
                c.bluestsdk_v2?.append(newCustomFw)
            }
        
            /**1. Make LOCAL Firmware DB request*/
            container = NSPersistentContainer(name: "BoardFirmware")
            container.loadPersistentStores() { (description, error) in
                self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                if let error = error {
                    fatalError("Failed to load Core Data stack: \(error)")
                }
            }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BoardFirmware")
            
            /**2. Delete LOCAL Firmware DB request in order to save new FRESH informations*/
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try container.viewContext.execute(deleteRequest)
            } catch let error as NSError {
                print(error)
            }
            
            /**3. Save FRESH Informations*/
            let managedContext = container.viewContext
            let boardFirmwareEntity = NSEntityDescription.entity(forEntityName: "BoardFirmware", in: managedContext)!
            let csmg = NSManagedObject(entity: boardFirmwareEntity, insertInto: managedContext) as! BoardFirmware
            csmg.setValue(catalogFirmwares, forKey: "firmwares")
        
            //SAVE DB Data
            if container.viewContext.hasChanges {
                do {
                    try container.viewContext.save()
                } catch {
                    print("An error occurred while saving: \(error)")
                }
            }
            
            return true
            
        } else {
            return false
        }
    }
    
    public func getFwDetailsNode(device_id: Int, opt_byte_0: Int, opt_byte_1: Int) -> Firmware? {
        var fwDetail: Firmware?
        var bleFwId: Int
        
        var firmware: Firmware?
        
        if !(opt_byte_0 == 0x00){
            bleFwId = opt_byte_0
        }else{
            bleFwId = opt_byte_1+256
        }
        
        if(bleFwId<0){
            return nil
        }
        
        catalogFirmwares?.firmwares.forEach{ c in
            for fw in c.bluestsdk_v2! {
                if(device_id == __uint8_t(fw.ble_dev_id.dropFirst(2), radix: 16)! &&  __uint8_t(fw.ble_fw_id.dropFirst(2), radix: 16)! == bleFwId) {
                    firmware = fw
                }
            }
        }
        
        return firmware
        
    }
    
    /** DEBUG function that print Local DB firmware information */
    private func debugPrintDB(firmwares: Firmwares){
        print("*************")
        print("Board SDK V2")
        print("*************")
        for c in firmwares.firmwares{
            if !(c.bluestsdk_v2==nil){
                for fw in c.bluestsdk_v2! {
                    print("\n----------------------------------------------------------------")
                    print("\(fw.brd_name) [\(fw.ble_dev_id)][\(fw.ble_fw_id)] --- n*char:\(fw.characteristics.count)")
                    print("----------------------------------------------------------------")
                    
                    print(" \n*** CHARACTERISTICS ***")
                    for characteristic in fw.characteristics {
                        print(" - \(characteristic.name) [\(characteristic.uuid)]")
                        if !(characteristic.format_notify==nil) {
                            for formatN in characteristic.format_notify! {
                                print("     Properties Lenght: \(formatN.length!)")
                                print("       \(formatN.name!) -> \(formatN.length!)")
                            }
                        }
                    }
                    if !(fw.cloud_apps==nil){
                        print(" \n*** CLOUD APPS ***")
                        for cloudApp in fw.cloud_apps! {
                            print(" - Description: \(cloudApp.cloud_description)")
                            print(" - Dtmi: \(cloudApp.dtmi)")
                            print(" - Name: \(cloudApp.name)")
                            print(" - Shareable link: \(cloudApp.shareable_link)")
                            print(" - Url: \(cloudApp.url)")
                        }
                    }
                    debugPrintOptionBytesDB(fw: fw)
                }
            }
            
            print("\n\n\n")
            print("*************")
            print("Board SDK V1")
            print("*************")
            if !(c.bluestsdk_v1==nil){
                for fw in c.bluestsdk_v1! {
                    print("\n----------------------------------------------------------------")
                    print("\(fw.brd_name) [\(fw.ble_dev_id)][\(fw.ble_fw_id)] --- n*char:\(fw.characteristics.count)")
                    print("----------------------------------------------------------------")
                }
            }
            print("\n\n\n")
            print("***************")
            print("Characteristics")
            print("***************")
            print("\n")
            if !(c.characteristics==nil){
                for char in c.characteristics! {
                    print("\(char.name)")
                }
            }
        }
    }
    
    /** DEBUG function that print Local DB firmware information */
    private func debugPrintOptionBytesDB(fw: Firmware){
        if !(fw.option_bytes==nil){
            print(" \n*** OPTION_BYTES ***")
            for optBytes in fw.option_bytes! {
                
                if !(optBytes.name==nil){
                    print(" - \(optBytes.name) [Format: \(optBytes.format), Type: \(optBytes.type)]")

                    if !(optBytes.string_values==nil) {
                        print("   __STRING_VALUES__")
                        for stringValues in optBytes.string_values! {
                            print("       name: \(stringValues.display_name), value: \(stringValues.value)")
                        }
                    }
                    
                    if !(optBytes.icon_values==nil) {
                        print("   __ICON_VALUES__")
                        for iconValues in optBytes.icon_values! {
                            print("       comment: \(iconValues.comment), code: \(iconValues.icon_code), value: \(iconValues.value)")
                        }
                    }
                }
            }
        }
        
    }
    
}
