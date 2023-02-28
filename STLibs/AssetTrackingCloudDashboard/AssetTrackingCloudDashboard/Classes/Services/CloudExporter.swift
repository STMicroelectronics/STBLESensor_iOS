//
//  CloudExporter.swift
//  AssetTrackerCloudDashboard
//
//  Created by Giovanni Visentini on 06/02/2020.
//  Copyright © 2020 Giovanni Visentini. All rights reserved.
//

import Foundation
import AssetTrackingDataModel
import PKHUD

public enum CloudExporterError: Error {
    case invalidLogin
    case deviceRegistrationError
    case noNetwork
    case ioError
}

public class CloudExporter {
    public typealias CloudResult = Result<Void, CloudExporterError>
    public typealias CloudResultCompletion = (CloudResult) -> Void

    public typealias CloudProvisioningResult = Result<AssetTrackingDevice, CloudExporterError>
    public typealias CloudProvisioningResultCompletion = (CloudProvisioningResult) -> Void
    
    private var locationManager = LocationManager()
    private var deviceManager: (DeviceManager)? = nil

    public init(controller: UIViewController, deviceManager: DeviceManager?) {
        let loginManager = CloudConfig.atrLoginManager
        
        if(deviceManager != nil){
            self.deviceManager = deviceManager
        } else {
            /** Authenticate */
            loginManager.authenticate(from: controller) { [weak self] error in
                if let error = error as? AppAuthError {
                    //self?.manageLoginError(error, onComplete: onComplete)
                    return
                }
                
                /** device manager with auth */
                loginManager.buildDeviceManager { result in
                    switch result {
                    case .success(let deviceManager):
                        self?.deviceManager = deviceManager
                    case .failure(let error):
                        //self?.manageLoginError(AppAuthError.generic, onComplete: onComplete)
                        return
                    }
                }
            }
        }
    }
    
    /** Used to verify the board is really provisioned on Cloud DSH */
    public func verifyCompletedProvisioning(_ controller: UIViewController, device: AssetTrackingDevice, onComplete: @escaping (AssetTrackingDevice?) -> Void) {
        guard let deviceManager = deviceManager else { return }
        deviceManager.listDevices { [weak self] result in
            switch result {
                case .success(let devices):
                    devices.forEach { d in
                        if(d.id == device.id){
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Add Device", message: "Operation completed.\nDevice registered properly.", preferredStyle: .alert)
                                let okButton = UIAlertAction(title: "Ok", style: .default){ _ in
                                    controller.navigationController?.popToRootViewController(animated: true)
                                }
                                alert.addAction(okButton)
                                controller.present(alert, animated: true)
                            }
                        }
                    }
                    break
                case .failure(_):
                    return onComplete(nil)
                    break
            }
        }
    }
    
    public func exportAstraData(device: AssetTrackingDevice, data: [DataSample], location: Location?, from controller: UIViewController, onComplete: @escaping CloudResultCompletion) {
        guard let deviceManager = deviceManager else { return }
        if(location != nil){
            self.checkAstraCloudMatch(deviceManager: deviceManager, device: device, data: data, location: location!, from: controller, onComplete: onComplete)
        }else{
            self.checkCloudMatch(deviceManager: deviceManager, device: device, data: data, from: controller, onComplete: onComplete)
        }
    }
    
    public func exportData(device: AssetTrackingDevice, data: [DataSample], from controller: UIViewController, onComplete: @escaping CloudResultCompletion) {
        guard let deviceManager = deviceManager else { return }
        self.checkCloudMatch(deviceManager: deviceManager, device: device, data: data, from: controller, onComplete: onComplete)
    }
    
    public func createDevice(device: AssetTrackingDevice, macAddress: String?, deviceProfile: String?, devEui: String?, from controller: UIViewController, onComplete: @escaping CloudProvisioningResultCompletion) {
        let loginManager = CloudConfig.atrLoginManager
        
        /** Authenticate */
        loginManager.authenticate(from: controller) { [weak self] error in
            if let error = error as? AppAuthError {
                self?.manageLoginError(error, onComplete: onComplete)
                return
            }
            
            /** device manager with auth */
            loginManager.buildDeviceManager { result in
                switch result {
                case .success(let deviceManager):
                    
                    /** check if device is in cloud */
                    deviceManager.listDevices { result in
                        guard case .success(let devices) = result else {
                            return onComplete(.failure(.deviceRegistrationError))
                        }
                        
                        /** add Device */
                        deviceManager.addDevice(device: device, name: device.label!, certificate: nil, macaddress: macAddress, deviceprofile: deviceProfile, devEui: devEui) { addResult in
                            guard case .success(let certifiedDevice) = addResult else {
                                DispatchQueue.main.async { HUD.flash(.labeledError(title: "Cloud error", subtitle: "Could not add device"), onView: controller.view, delay: 3) }
                                return onComplete(.failure(.deviceRegistrationError))
                            }
                            return onComplete(.success(device))
                        }
                    }
                case .failure(let error):
                    self?.manageLoginError(AppAuthError.generic, onComplete: onComplete)
                }
            }
            
        }
    }
    
    public func getDefaultDeviceProfile(controller: UIViewController, onComplete: @escaping ( (DeviceManager)?, DeviceProfile? ) -> Void){
        
        var dPs: [DeviceProfile] = []
        var dM: (DeviceManager)? = nil
        
        DispatchQueue.main.async {
            let loginManager = CloudConfig.atrLoginManager
            
            /** Authenticate */
            loginManager.authenticate(from: controller) { [weak self] error in
                if let error = error as? AppAuthError {
                    return onComplete(nil, nil)
                }
                
                /** device manager with auth */
                loginManager.buildDeviceManager { result in
                    switch result {
                        case .success(let deviceManager):
                            dM = deviceManager
                            deviceManager.defaultDeviceProfile { [weak self] result in
                                switch(result){
                                    case .success(let deviceProfile):
                                        return onComplete(dM, deviceProfile)
                                    case .failure:
                                        return onComplete(nil, nil)
                                }
                            }
                        case .failure(let error):
                            return onComplete(nil, nil)
                    }
                }
            }
        }
    }
    
    public func getOtherDeviceProfiles(dM: (DeviceManager)?, onComplete: @escaping ([DeviceProfile]?) -> Void){
        DispatchQueue.main.async {
            if !(dM==nil){
                dM!.deviceProfiles { [weak self] result in
                    switch(result){
                        case .success(let dProfiles):
                            return onComplete(dProfiles)
                        case .failure:
                            return onComplete(nil)
                    }
                }
            }
        }
    }
    
    public func requestLocationAuthorization(completion: @escaping LocationManager.Completion) {
        locationManager.readCurrentLocation(onComplete: completion)
    }
}


private extension CloudExporter {
    // step 1 -> START
    func checkCloudMatch(deviceManager: DeviceManager, device: AssetTrackingDevice, data: [DataSample], from controller: UIViewController, onComplete: @escaping CloudResultCompletion) {
        locationManager.readCurrentLocation { [weak self] location in
            guard let location = location else { return }
            AssetTrackingBroadcastEvents.sendNewPosition(location) // store position for current session
            
            // check if device is in cloud
            deviceManager.listDevices { result in
                guard case .success(let devices) = result else {
                    return onComplete(.failure(.deviceRegistrationError))
                }
                
                guard devices.first(where: { $0.id == device.id }) == nil else {
                // device already in cloud -> step 3
                    self?.getApikey(deviceManager: deviceManager, boardId: device.id, location: location, data: data, onComplete: onComplete)
                    return
                }
                
                self?.createCloudDevice(deviceManager: deviceManager, device: device, location: location, data: data, from: controller, onComplete: onComplete)
            }
        }
    }
    
    func checkAstraCloudMatch(deviceManager: DeviceManager, device: AssetTrackingDevice, data: [DataSample], location: Location, from controller: UIViewController, onComplete: @escaping CloudResultCompletion) {
        AssetTrackingBroadcastEvents.sendNewPosition(location) // store position for current session
        
        // check if device is in cloud
        deviceManager.listDevices { result in
            guard case .success(let devices) = result else {
                return onComplete(.failure(.deviceRegistrationError))
            }
            
            guard devices.first(where: { $0.id == device.id }) == nil else {
            // device already in cloud -> step 3
                self.getApikey(deviceManager: deviceManager, boardId: device.id, location: location, data: data, onComplete: onComplete)
                return
            }
            
            self.createCloudDevice(deviceManager: deviceManager, device: device, location: location, data: data, from: controller, onComplete: onComplete)
        }
    }
    
    // step 2
    func createCloudDevice(deviceManager:DeviceManager, device: AssetTrackingDevice, location:Location, data: [DataSample], from controller: UIViewController, onComplete: @escaping CloudResultCompletion) {
        
        DispatchQueue.main.async {
            let createVC = DashboardCreateViewController(deviceManager: deviceManager, device: device) { [weak self] device, name, presentedVC in
                
                DispatchQueue.main.async {  HUD.show(.progress, onView: presentedVC.view) }
                
                deviceManager.addDevice(device: device, name: name, certificate: nil, macaddress: nil, deviceprofile: nil, devEui: nil) { addResult in
                    guard case .success(let certifiedDevice) = addResult else {
                        DispatchQueue.main.async { HUD.flash(.labeledError(title: "Cloud error", subtitle: "Could not add device"), onView: presentedVC.view, delay: 3) }
                        return onComplete(.failure(.deviceRegistrationError))
                    }
                    
                    DispatchQueue.main.async {
                        HUD.hide()
                        presentedVC.dismiss(animated: true) {
                            self?.getApikey(deviceManager: deviceManager, boardId: certifiedDevice.id, location: location, data: data, onComplete: onComplete)
                        }
                    }
                }
            }
            
            controller.present(createVC, animated: true)
        }
    }
    
    // step 3
    func getApikey(deviceManager: DeviceManager, boardId: String, location: Location, data: [DataSample], onComplete: @escaping CloudResultCompletion) {
        deviceManager.apiKey { [weak self] result in
            guard case .success(let apikey) = result else {
                return onComplete(.failure(.deviceRegistrationError))
            }
            
            self?.exportDataAndLocationTo(deviceManager: deviceManager, boardId: boardId, location: location, data: data, apiKey: apikey, onComplete: onComplete)
        }
    }
    
    // step 4 -> END
    func exportDataAndLocationTo(deviceManager: DeviceManager, boardId: String, location: Location, data: [DataSample], apiKey: ApiKey, onComplete: @escaping CloudResultCompletion) {
        
        deviceManager.saveData(deviceId: boardId, samples: data, currentLocation: location, apikey: apiKey) { pushDataResult in
            switch(pushDataResult){
            case .success:
                onComplete(.success(()))
            case .failure(_):
                onComplete(.failure(.ioError))
            }
        }
    }
    
    func manageLoginError(_ error: AppAuthError, onComplete: @escaping CloudProvisioningResultCompletion) {
        switch error {
        case .invalidState:
            onComplete(.failure(.invalidLogin))
        case .generic:
            onComplete(.failure(.invalidLogin))
        }
    }
}
