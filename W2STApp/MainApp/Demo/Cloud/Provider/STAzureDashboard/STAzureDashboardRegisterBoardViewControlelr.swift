//
//  STAzureDashboardRegisterBoardViewControlelr.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 12/11/2019.
//  Copyright © 2019 STMicroelectronics. All rights reserved.
//

import Foundation
import MBProgressHUD

class STAzureDashboardRegisterBoardViewController: UIViewController {
    
    private static let CREATE_NEW_GROUP_URL = URL(string: "https://stm32ode.azurewebsites.net//#/signup")!

    
    static func instantiate(deviceId: String, deviceName:String, onClose:@escaping ()->()) -> UIViewController{
        let storyBoard = UIStoryboard(name: "CloudDemo", bundle: Bundle(for: STAzureDashboardRegisterBoardViewController.self))
        
        let vc = storyBoard.instantiateViewController(withIdentifier: "STAzureDashboardRegisterBoardViewController") as! STAzureDashboardRegisterBoardViewController
        
        vc.deviceId = deviceId
        vc.deviceName = deviceName
        vc.closeCallback = onClose
        return vc
    }
    
    private var deviceId:String!
    private var deviceName:String!
    private var closeCallback:(()->())?
    
    
    @IBOutlet weak var groupNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    private var progressBar : MBProgressHUD?
    
    private func createLoginProgressBar() -> MBProgressHUD{
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.removeFromSuperViewOnHide = true
        hud.label.text = Self.LOGGIN
        return hud
    }
    
    private let loginManager = STAzureUserManager()
        
    @IBAction func onRegisterButtonPressed(_ sender: UIButton) {
        guard let groupName = groupNameText.text else{
            showAllert(title: Self.INVALID_DATA_TITLE, message: Self.INVALID_GROUP)
            return
        }
        guard let password = passwordText.text else{
            showAllert(title: Self.INVALID_DATA_TITLE, message: Self.INVALID_PASSOWRD)
            return
        }
        
        progressBar = createLoginProgressBar()
        progressBar?.show(animated: true)
        loginManager.login(name: groupName, password: password){ [weak self] result in
            switch(result){
            case .success(let authData):
                self?.registerDevice(authData: authData)
            case .failure(let error):
                self?.manageLoginError(error: error)
            }
        }
    }
    
    private func registerDevice(authData:STAzureAuthData){
        guard let deviceManager = loginManager.getDeviceManager(authData: authData) else{
            manageLoginError(error: .invalidResponse)
            return
        }
        progressBar?.label.text = Self.REGISTERING
        deviceManager.register(deviceId: deviceId, deviceName: deviceName){ [weak self] result in
            switch(result){
            case .success(let registeredDevice):
                self?.onDeviceRegistrationComplete(registeredDevice)
            case .failure(let error):
                self?.manageRegistrationError(error: error)
            }
        }
    }
    
    private func onDeviceRegistrationComplete(_ device:STAzureRegisterdDevice){
        progressBar?.hide(animated: true)
        STAzureRegistredDeviceDB.instance.registerdDeviceDao.add(device: device)
        closeCallback?()
        dismiss(animated: true, completion: nil)
    }
    
    private func manageRegistrationError(error:STAzureDeviceRegistrationError){
        
        progressBar?.hide(animated: true)
        switch error {
        case .accessForbidden:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_ACCESS_FORBIDDEN)
        case .invalidParameters:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_INVALID_PARAM)
        case .invalidResponse:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_INVALID_RESPONSE)
        case .offline:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_OFFLINE)
        default:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_IO)
        }
    }
    @IBAction func onCreateNewGroupPressed(_ sender: UIButton) {
        UIApplication.shared.open(Self.CREATE_NEW_GROUP_URL)
    }
    
    private func manageLoginError(error:STAzureLoginError){
        progressBar?.hide(animated: true)
        switch error {
        case .accessForbidden:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_ACCESS_FORBIDDEN)
        case .invalidParameters:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_INVALID_PARAM)
        case .invalidResponse:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_INVALID_RESPONSE)
        case .offline:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_OFFLINE)
        case .ioError:
            showAllert(title: Self.ERROR_TITLE, message: Self.ERROR_IO)
        }
    }
    
    @IBAction func onCancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

private extension STAzureDashboardRegisterBoardViewController{
    
    static let LOGGIN:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Loggin...", tableName: nil, bundle: bundle,
                                 value: "Loggin...", comment: "")
    }();
    
    static let REGISTERING:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Registering...", tableName: nil, bundle: bundle,
                                 value: "Registering...", comment: "")
    }();
    
    
    static let INVALID_DATA_TITLE:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Invalid Data", tableName: nil, bundle: bundle,
                                 value: "Invalid Data", comment: "")
    }();
    
    static let INVALID_GROUP:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Empty group name", tableName: nil, bundle: bundle,
                                 value: "Empty group name", comment: "")
    }();
    
    static let INVALID_PASSOWRD:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Empty password", tableName: nil, bundle: bundle,
                                 value: "Empty password", comment: "")
    }();
    
    static let ERROR_TITLE:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Error", tableName: nil, bundle: bundle,
                                 value: "Error", comment: "")
    }();
    
    static let ERROR_ACCESS_FORBIDDEN:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Access forbidden", tableName: nil, bundle: bundle,
                                 value: "Access forbidden", comment: "")
    }();
    
    static let ERROR_OFFLINE:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Missing internet connection", tableName: nil, bundle: bundle,
                                 value: "Missing internet connection", comment: "")
    }();
    
    static let ERROR_INVALID_PARAM:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Invalid input data", tableName: nil, bundle: bundle,
                                 value: "Invalid input data", comment: "")
    }();
    
    static let ERROR_INVALID_RESPONSE:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Server error: invalid response", tableName: nil, bundle: bundle,
                                 value: "Server error: invalid response", comment: "")
    }();
    
    static let ERROR_IO:String = {
        let bundle = Bundle(for: STAzureDashboardRegisterBoardViewController.self)
        return NSLocalizedString("Communication error", tableName: nil, bundle: bundle,
                                 value: "Communication error", comment: "")
    }();
    
}
