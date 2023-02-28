//
//  AssetTrackingLoginViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import PKHUD
import STTheme
import WebKit
import Toast_Swift
import AppTrackingTransparency

public protocol DeviceManagerDelegate: AnyObject {
    func controller(_ controller: UIViewController, didCompleteDeviceManager deviceManager: DeviceManager)
}

public class AssetTrackingLoginViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginImage: UIImageView!
    
    public typealias LoginCompletion = (DeviceManager?) -> Void
    
    var webView: WKWebView!
    
    public weak var delegate: DeviceManagerDelegate?
    
    public var loginManager = CloudConfig.atrLoginManager
    
    func requestAppTrackingTransparencyPermission() {
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        print("Authorized")
                        DispatchQueue.main.async {
                            self.performLogin()
                        }
                    case .denied:
                        print("Denied")
                        DispatchQueue.main.async {
                            self.showPermissionRequiredAlert()
                        }
                    case .notDetermined:
                        print("Not Determined")
                    case .restricted:
                        print("Restricted")
                        DispatchQueue.main.async {
                            self.showPermissionRequiredAlert()
                        }
                    @unknown default:
                        print("Unknown")
                    }
                }
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.setTitleColor(ThemeService.shared.currentTheme.color.primary, for: .normal)
        
        title = "Login"
        
        if(loginManager is PredmntLoginManager){
            loginImage.image = UIImage(named: "predmnt_login", in: AssetTrackingCloudBundle.bundle(), compatibleWith: nil)
        } else {
            loginImage.image = AssetTrackingCloudBundle.bundleImage(named: "atr_login")
        }
        self.onLoginButtonPressed()
    }
    
    private func showProgressView(){
        DispatchQueue.main.async { HUD.show(.progress, onView: self.view) }
    }
    private func hideProgressView(){
        DispatchQueue.main.async { HUD.hide() }
    }
    
    @IBAction func onLoginButtonPressed() {
        /*if #available(iOS 14, *) {
            requestAppTrackingTransparencyPermission()
        } else {
            self.performLogin()
        }*/
        self.performLogin()
    }
    
    func performLogin(){
        showProgressView()
        doAuthentication { [weak self] dM in
            guard dM != nil else {
                self?.hideProgressView()
                self?.updateUI(isAuthenticated: false)
                self?.showLoginError("Authentication failed. Please try again.")
                self?.loginManager.resetAuthentication()
                return
            }
            self?.hideProgressView()
            DispatchQueue.main.async {
                self?.makeDeviceManagerDelegate(deviceManager: dM!)
            }
        }
    }

    func doAuthentication(onComplete: @escaping LoginCompletion) {
        loginManager.authenticate(from: self) { [weak self] error in
            if let error = error {
                onComplete(nil)
            }
            
            let idTokenN = UserDefaults.standard.string(forKey: "idTokenN") ?? ""
            let accessTokenN = UserDefaults.standard.string(forKey: "accessTokenN") ?? ""
            var checkedLA = UserDefaults.standard.bool(forKey: "showLA")
            
            if(checkedLA){
                self!.webView = WKWebView()
                self!.webView.navigationDelegate = self
                self!.webView.configuration.preferences.javaScriptEnabled = true
                
                self!.webView?.sizeToFit()
                self!.view = self!.webView
                let url = URL(string: Environment.current.endpoints.webUrl + "?id_token=\(idTokenN)&access_token=\(accessTokenN)")!
                
                self!.webView.load(URLRequest(url: url))
            }else{
                self?.loginManager.buildDeviceManager { result in
                    switch result {
                        case .success(let deviceManager):
                            onComplete(deviceManager)
                        case .failure:
                            onComplete(nil)
                    }
                }
            }
        }
    }
    
    func makeDeviceManagerDelegate(deviceManager: (DeviceManager)){
        guard let delegate = self.delegate else {
            return
        }
        delegate.controller(self, didCompleteDeviceManager: deviceManager)
        if(loginManager is AtrLoginManager) {
            self.navigationController?.dismiss(animated: true)
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.absoluteString {
            if host.contains(Environment.current.endpoints.webLogoutUrl) {
                webView.stopLoading()
                decisionHandler(.cancel)
                self.onLoginButtonPressed()
                return
            }
        }
        decisionHandler(.allow)
    }
}

private extension AssetTrackingLoginViewController {
    func updateUI(isAuthenticated: Bool) {
        DispatchQueue.main.async {
            self.loginButton.isHidden = isAuthenticated
        }
    }
    
    func gotoDashboard(deviceManager: DeviceManager) {
        let vc = DashboardListViewController(deviceManager: deviceManager)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLoginError(_ msg:String){
        DispatchQueue.main.async {
            self.view.makeToast(msg, duration: 2)
            //self.showMessage(title: AssetTrackingLoginViewController.LOGIN_ERROR_TITLE, msg: msg)
        }
    }
    
    static let LOGIN_ERROR_TITLE =  {
        return  NSLocalizedString("Login Error",
                                  tableName: nil,
                                  bundle: AssetTrackingCloudBundle.bundle(),
                                  value: "Login Error",
                                  comment: "Login Error");
    }()
    
    static let NO_NETWORK =  {
        return  NSLocalizedString("Mobile offline, check the Internet connection",
                                  tableName: nil,
                                  bundle: AssetTrackingCloudBundle.bundle(),
                                  value: "Mobile offline, check the Internet connection",
                                  comment: "Mobile offline, check the Internet connection");
    }()
    
    static let INVALID_CREDENTIALS =  {
        return  NSLocalizedString("Invalid user name or password",
                                  tableName: nil,
                                  bundle: AssetTrackingCloudBundle.bundle(),
                                  value: "Invalid user name or password",
                                  comment: "Invalid user name or password");
    }()
    
    static let UNKNWON_ERROR =  {
        return  NSLocalizedString("Unknown error",
                                  tableName: nil,
                                  bundle: AssetTrackingCloudBundle.bundle(),
                                  value: "Unknown error",
                                  comment: "Unknown error");
    }()
    
    static let LOGIN_COMPLETED =  {
        return  NSLocalizedString("Login Completed",
                                  tableName: nil,
                                  bundle: AssetTrackingCloudBundle.bundle(),
                                  value: "Login Completed",
                                  comment: "Login Completed");
    }()
    
    func showPermissionRequiredAlert() {
        let showAlert = UIAlertController(title: "Permission Required", message: "Permission required to perform login. Please go to Settings > Privacy & Security > Tracking and Allow Apps to Request to Track.\nThen click GO button to allow App Tracking.", preferredStyle: .alert)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 150, width: 250, height: 255))
        imageView.image = UIImage(named: "permissionrequired", in: AssetTrackingCloudBundle.bundle(), compatibleWith: nil)!
        showAlert.view.addSubview(imageView)
        let height = NSLayoutConstraint(item: showAlert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 460)
        let width = NSLayoutConstraint(item: showAlert.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        showAlert.view.addConstraint(height)
        showAlert.view.addConstraint(width)
        showAlert.addAction(UIAlertAction(title: "GO", style: .default, handler: { action in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }))
        self.present(showAlert, animated: true, completion: nil)
    }
}
