//
//  STAzureRegisterdDeviceDaoCodeData.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 15/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation
import CoreData

internal class STAzureRegisterdDeviceDaoCoreData: STAzureRegisterDeviceDao {
    
    private var mObjContext: NSManagedObjectContext
    
    init() {
        let application = UIApplication.shared.delegate as! BlueMSAppDelegate
        mObjContext = application.persistentContainer.viewContext
    }
    
    private func getDeviceEntry(id:String) -> STAzureRegisterdDeviceEntity?{
        let deviceWithId:NSFetchRequest<STAzureRegisterdDeviceEntity> = STAzureRegisterdDeviceEntity.fetchRequest()
        deviceWithId.predicate = NSPredicate(format:"id = %@",id)
        deviceWithId.returnsObjectsAsFaults = false
        deviceWithId.fetchLimit = 1
        do{
            let knowDevice = try mObjContext.fetch(deviceWithId)
            guard knowDevice.count >= 1 else{
                return nil
            }
            return knowDevice[0]
        }catch let error{
            print(error)
            return nil
        }
    }
     
    func getRegisterDevice(id: String) -> STAzureRegisterdDevice? {
        guard let deviceWithId = getDeviceEntry(id: id) else{
            return nil
        }
        guard let id = deviceWithId.id, let name = deviceWithId.name, let cs = deviceWithId.connectionString else{
            return nil
        }
        return STAzureRegisterdDevice(id: id, name: name, connectionString: cs)
        
    }
    
    func add(device: STAzureRegisterdDevice) {
        var deviceEntity = getDeviceEntry(id: device.id)
        if(deviceEntity==nil){
            let entity = NSEntityDescription.entity(forEntityName: "STAzureRegisterdDeviceEntity", in: mObjContext)
            deviceEntity = STAzureRegisterdDeviceEntity(entity: entity!, insertInto: mObjContext)
        }
        deviceEntity?.id = device.id
        deviceEntity?.name = device.name
        deviceEntity?.connectionString = device.connectionString
        
        do {
            try mObjContext.save()
        } catch let error {
            print(error)
        }
    }
    
    
}
