/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
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

public class BlueMSCloudIBMWatsonIOTConfigViewController : BlueMSCloudConfigDetailsViewController{
    
    private static let ORGANIZATION_KEY = "BlueMSCloudIBMWatsonIOTConfigViewController.organization"
    private static let AUTH_KEY = "BlueMSCloudIBMWatsonIOTConfigViewController.auth"
    private static let DEVICE_ID_KEY = "BlueMSCloudIBMWatsonIOTConfigViewController.deviceId"
    private static let DEVICE_TYPE_KEY = "BlueMSCloudIBMWatsonIOTConfigViewController.deviceType"
    
    @IBOutlet weak var mDeviceIdText: UITextField!
    @IBOutlet weak var mDeviceTypeText: UITextField!
    @IBOutlet weak var mAuthTockenText: UITextField!
    @IBOutlet weak var mOrganizationText: UITextField!
    
    private var nodeType:String!
    
    public override func viewDidLoad() {
        setTextFieldDelegate()
    }
    
    private func storeSettings(){
        let settings = UserDefaults.standard;
        settings.set(mOrganizationText.text, forKey: BlueMSCloudIBMWatsonIOTConfigViewController.ORGANIZATION_KEY)
        settings.set(mAuthTockenText.text, forKey: BlueMSCloudIBMWatsonIOTConfigViewController.AUTH_KEY)
        settings.set(mDeviceIdText.text, forKey: BlueMSCloudIBMWatsonIOTConfigViewController.DEVICE_ID_KEY)
        settings.set(mDeviceTypeText.text, forKey: BlueMSCloudIBMWatsonIOTConfigViewController.DEVICE_TYPE_KEY)
        settings.synchronize()
    }
    
    private func loadSettings(){
        let settings = UserDefaults.standard;
        mOrganizationText.text = settings.string(forKey: BlueMSCloudIBMWatsonIOTConfigViewController.ORGANIZATION_KEY)
        mAuthTockenText.text = settings.string(forKey: BlueMSCloudIBMWatsonIOTConfigViewController.AUTH_KEY)
        mDeviceIdText.text = settings.string(forKey: BlueMSCloudIBMWatsonIOTConfigViewController.DEVICE_ID_KEY)
        mDeviceTypeText.text = settings.string(forKey: BlueMSCloudIBMWatsonIOTConfigViewController.DEVICE_TYPE_KEY)
    }
    
    private func setTextFieldDelegate(){
        mOrganizationText.delegate=self;
        mAuthTockenText.delegate=self;
        mDeviceIdText.delegate=self;
        mDeviceTypeText.delegate=self;
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSettings()
        
        if( mDeviceIdText.text == nil || mDeviceIdText.text?.count == 0){
            mDeviceIdText.text = W2STCloudConfigViewController.getDeviceId(for: self.node)
        }
        
        if( mDeviceTypeText.text == nil || mDeviceTypeText.text?.count == 0){
            mDeviceTypeText.text = BlueSTSDKNode.nodeType(toString: self.node.type)
        }
    }
    
    public override func buildConnectionFactory() -> BlueMSCloudIotConnectionFactory? {
        if let deviceId = mDeviceIdText.text, !deviceId.isEmpty,
           let organization = mOrganizationText.text , !organization.isEmpty,
           let nodeType = mDeviceTypeText.text , !nodeType.isEmpty,
           let auth = mAuthTockenText.text , !auth.isEmpty{
            storeSettings()
            showDetailsButton()
            return BlueMSIBMWatsonIOTConnectionFactory(organization: organization, deviceType: nodeType, deviceId: deviceId, authTocken: auth)
        }
        return nil;
    }
}

extension BlueMSCloudIBMWatsonIOTConfigViewController : UITextFieldDelegate{
    //hide keyboard when the user press return
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
