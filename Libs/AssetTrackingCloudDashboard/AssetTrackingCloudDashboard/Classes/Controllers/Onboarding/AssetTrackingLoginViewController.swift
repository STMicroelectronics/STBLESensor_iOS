//
//  AssetTrackingLoginViewController.swift
//  SmarTagCloudAssetTracking
//
//  Created by Giovanni Visentini on 20/08/2019.
//  Copyright © 2019 Giovanni Visentini. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import STTheme
import WebKit

class AssetTrackingLoginViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    var webView: WKWebView!
    
    private let loginManager = CloudConfig.loginManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.setTitleColor(ThemeService.shared.currentTheme.color.primary, for: .normal)
        
        let authenticated = loginManager.isAuthenticated
        updateUI(isAuthenticated: loginManager.isAuthenticated)
        
        if loginManager.isAuthenticated {
            HUD.show(.progress, onView: self.view)
            
            loginManager.buildDeviceManager { result in
                DispatchQueue.main.async {
                    HUD.hide()
                    switch result {
                    case .success(let deviceManager):
                        self.gotoDashboard(deviceManager: deviceManager)
                    case .failure:
                        self.onLoginButtonPressed()
                    }
                }
            }
            //onLoginButtonPressed()
        }else{
            onLoginButtonPressed()
        }
    }
    
    @IBAction func onLoginButtonPressed() {
        DispatchQueue.main.async { HUD.show(.progress, onView: self.view) }
        
        loginManager.authenticate(from: self) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    HUD.hide()
                    //self?.showLoginError(AssetTrackingLoginViewController.INVALID_CREDENTIALS)
                    self?.updateUI(isAuthenticated: false)
                    return
                }
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
                    DispatchQueue.main.async {
                        HUD.hide()
                        switch result {
                        case .success(let deviceManager):
                            self?.gotoDashboard(deviceManager: deviceManager)
                        case .failure:
                            self?.showLoginError("You session has expired, please authenticate again.")
                            self?.updateUI(isAuthenticated: false)
                        }
                    }
                }
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
        titleLabel.text = isAuthenticated ? "Loading profile..." : "Account login"
        loginButton.isHidden = isAuthenticated
    }
    
    func gotoDashboard(deviceManager: DeviceManager) {
        let vc = DashboardListViewController(deviceManager: deviceManager)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLoginError(_ msg:String){
        DispatchQueue.main.async {
            self.showMessage(title: AssetTrackingLoginViewController.LOGIN_ERROR_TITLE, msg: msg)
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
}
