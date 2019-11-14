/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

import Foundation

internal class BlueMSAzureIotCentralViewController : BlueMSCloudConfigDetailsViewController{
    
    private static let SCOPE_ID_KEY = "BlueMSAzureIotCentraViewController.scopeId"
    private static let AUTH_KEY = "BlueMSAzureIotCentraViewController.symKey"
    private static let DEVICE_ID_KEY = "BlueMSAzureIotCentraViewController.deviceId"
    private static let CREATE_NEW_APP_URL = URL(string: "https://apps.azureiotcentral.com/create?appTemplate=771a66fa-f16c-47b5-abcd-8db027a754e2")!
    
    private static let MISSING_DATA_TITLE:String = {
        let bundle = Bundle(for: BlueMSAzureIotCentralViewController.self)
        return NSLocalizedString("Missing data", tableName: nil, bundle: bundle,
                                 value: "Missing data", comment: "")
    }();
    
    private static let MISSING_SCOPEID:String = {
        let bundle = Bundle(for: BlueMSAzureIotCentralViewController.self)
        return NSLocalizedString("Invalid Scope Id", tableName: nil, bundle: bundle,
                                 value: "Invalid Scope Id", comment: "")
    }();
    
    private static let MISSING_APP_KEY:String = {
        let bundle = Bundle(for: BlueMSAzureIotCentralViewController.self)
        return NSLocalizedString("Invalid Application key", tableName: nil, bundle: bundle,
                                 value: "Invalid Application key", comment: "")
    }();
    
    private static let MISSING_DEVICE_ID:String = {
        let bundle = Bundle(for: BlueMSAzureIotCentralViewController.self)
        return NSLocalizedString("Invalid Device ID", tableName: nil, bundle: bundle,
                                 value: "Invalid Device ID", comment: "")
    }();
    
    @IBOutlet weak var mScopeIdText: UITextField!
    @IBOutlet weak var mDeviceIdText: UITextField!
    @IBOutlet weak var mSymKeyText: UITextField!
    
    private func isValidScopeId(_ scopeid:String?)->Bool{
        return !scopeid.isNullOrEmpty
    }
    
    private func isValidKey(_ key:String?)->Bool{
        return !key.isNullOrEmpty
    }
    
    private func isValidDeviceID(_ device:String?)->Bool{
        guard let dev = device else{
            return false
        }
        return !dev.isEmpty && dev == dev.lowercased()
    }
    
    override func buildConnectionFactory()->BlueMSCloudIotConnectionFactory?{
        
        guard let scopeId = mScopeIdText.text?.removeWhitespaces(),
            isValidScopeId(scopeId) else {
            showAllert( title: BlueMSAzureIotCentralViewController.MISSING_DATA_TITLE,
                        message: BlueMSAzureIotCentralViewController.MISSING_SCOPEID)
            return nil;
        }
        
        guard let deviceId = mDeviceIdText.text?.removeWhitespaces(),
            isValidDeviceID(deviceId) else {
            showAllert( title: BlueMSAzureIotCentralViewController.MISSING_DATA_TITLE,
                        message: BlueMSAzureIotCentralViewController.MISSING_DEVICE_ID)
            return nil;
        }
        
        guard let symKey = mSymKeyText.text?.removeWhitespaces(),
            isValidKey(symKey) else {
            showAllert( title: BlueMSAzureIotCentralViewController.MISSING_DATA_TITLE,
                        message: BlueMSAzureIotCentralViewController.MISSING_APP_KEY)
            return nil;
        }
        
        storeSettings()
        showDetailsButton()
        return BlueMSAzureIotCentralConnectionFactory(deviceId: deviceId, scopeId: scopeId, symKey: symKey)
        
    }
    
    private func storeSettings(){
        let settings = UserDefaults.standard;
        settings.set(mScopeIdText.text, forKey: BlueMSAzureIotCentralViewController.SCOPE_ID_KEY)
        settings.set(mDeviceIdText.text, forKey: BlueMSAzureIotCentralViewController.DEVICE_ID_KEY)
        settings.set(mSymKeyText.text, forKey: BlueMSAzureIotCentralViewController.AUTH_KEY)
        settings.synchronize()
    }
    
    private func loadSettings(){
        let settings = UserDefaults.standard;
        mScopeIdText.text = settings.string(forKey: BlueMSAzureIotCentralViewController.SCOPE_ID_KEY)
        mDeviceIdText.text = settings.string(forKey: BlueMSAzureIotCentralViewController.DEVICE_ID_KEY)
        mSymKeyText.text = settings.string(forKey: BlueMSAzureIotCentralViewController.AUTH_KEY)
       
    }
    
    @IBAction func onCreateApplicationPressed(_ sender: UIButton) {
        UIApplication.shared.open(BlueMSAzureIotCentralViewController.CREATE_NEW_APP_URL)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
    }
}

fileprivate extension Optional where Wrapped == String {
    
    var isNullOrEmpty:Bool{
        get{
            return self?.isEmpty ?? true
        }
    }
}

fileprivate extension String {
    func removeWhitespaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
    }
}
