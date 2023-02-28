//
//  CertificateManager.swift
//  AssetTrackingCloudDashboard
//
//  Created by Dimitri Giani on 07/05/21.
//

import Foundation
import AssetTrackingDataModel
import PKHUD

public enum CertificateManagerError: Error {
    case invalidLogin
    case deviceRegistrationError
    case noNetwork
    case ioError
}

public class CertificateManager {
    public typealias CertificateManagerResult = Result<AssetTrackingDevice, CertificateManagerError>
    public typealias CertificateManagerResultCompletion = (CertificateManagerResult) -> Void

    public init() { }
    
    public func registerDevice(device: AssetTrackingDevice, certificate: String?, from controller: UIViewController, onComplete: @escaping CertificateManagerResultCompletion) {
        let loginManager = CloudConfig.atrLoginManager
        
        // authenticate
        loginManager.authenticate(from: controller) { [weak self] error in
            if let error = error as? AppAuthError {
                self?.manageLoginError(error, onComplete: onComplete)
                return
            }
            // device manager with auth
            loginManager.buildDeviceManager { result in
                switch result {
                case .success(let deviceManager):
                    self?.checkDevice(deviceManager: deviceManager, device: device, certificate: certificate, from: controller, onComplete: onComplete)
                case .failure(let error):
                    self?.manageLoginError(AppAuthError.generic, onComplete: onComplete)
                }
            }
            
        }
    }
}

private extension CertificateManager {
    func checkDevice(deviceManager: DeviceManager, device: AssetTrackingDevice, certificate: String?, from controller: UIViewController, onComplete: @escaping CertificateManagerResultCompletion) {
        // check if device is in cloud
        deviceManager.listDevices { [weak self] result in
            guard case .success(let devices) = result else {
                return onComplete(.failure(.deviceRegistrationError))
            }
            
            //  If there is a device, stop here and return current device
            if devices.first(where: { $0.id == device.id }) != nil {
                self?.getApikey(deviceManager: deviceManager, device: device, onComplete: onComplete)
                return
            }
            
            self?.createCloudDevice(deviceManager: deviceManager, device: device, certificate: certificate, from: controller, onComplete: onComplete)
        }
    }
    
    func createCloudDevice(deviceManager:DeviceManager, device: AssetTrackingDevice, certificate: String?, from controller: UIViewController, onComplete: @escaping CertificateManagerResultCompletion) {
        
        DispatchQueue.main.async {
            let createVC = DashboardCreateViewController(deviceManager: deviceManager, device: device) { [weak self] device, name, presentedVC in
                
                DispatchQueue.main.async {  HUD.show(.progress, onView: presentedVC.view) }
                
                deviceManager.addDevice(device: device, name: name, certificate: certificate, macaddress: nil, deviceprofile: nil, devEui: nil) { addResult in
                    guard case .success(let certifiedDevice) = addResult else {
                        DispatchQueue.main.async { HUD.flash(.labeledError(title: "Error", subtitle: "Could not add device"), onView: presentedVC.view, delay: 3) }
                        return onComplete(.failure(.deviceRegistrationError))
                    }
                    
                    DispatchQueue.main.async {
                        HUD.hide()
                        presentedVC.dismiss(animated: true) {
                            self?.getApikey(deviceManager: deviceManager, device: certifiedDevice, onComplete: onComplete)
                        }
                    }
                }
            }
            
            controller.present(createVC, animated: true)
        }
    }
    
    func getApikey(deviceManager: DeviceManager, device: AssetTrackingDevice, onComplete: @escaping CertificateManagerResultCompletion) {
        deviceManager.apiKey { [weak self] result in
            guard case .success(let apikey) = result else {
                return onComplete(.failure(.deviceRegistrationError))
            }
            
            onComplete(.success(device))
        }
    }
    
    func manageLoginError(_ error: AppAuthError, onComplete: @escaping CertificateManagerResultCompletion) {
        switch error {
        case .invalidState:
            onComplete(.failure(.invalidLogin))
        case .generic:
            onComplete(.failure(.invalidLogin))
        }
    }
}
