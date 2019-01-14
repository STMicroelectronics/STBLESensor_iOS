/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
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

public class BlueMSGenericMqttConfigurationViewController : BlueMSCloudConfigDetailsViewController{
    
    private static let BROCKER_KEY = "BlueMSGenericMqttConfigurationViewController_brocker"
    private static let PORT_KEY = "BlueMSGenericMqttConfigurationViewController_port"
    private static let USER_KEY = "BlueMSGenericMqttConfigurationViewController_user"
    private static let USE_TLS_KEY = "BlueMSGenericMqttConfigurationViewController_useTls"
    private static let CLIENT_ID_KEY = "BlueMSGenericMqttConfigurationViewController_clientId"
    
    @IBOutlet weak var mBrokerText: UITextField!
    @IBOutlet weak var mPortText: UITextField!
    @IBOutlet weak var mUserText: UITextField!
    @IBOutlet weak var mPasswordText: UITextField!
    @IBOutlet weak var mClientText: UITextField!
    @IBOutlet weak var mTlsSwtich: UISwitch!
  
    private func storeSettings(){
        let defaults = UserDefaults.standard
        defaults.set(mBrokerText.text, forKey: BlueMSGenericMqttConfigurationViewController.BROCKER_KEY)
        defaults.set(mPortText.text, forKey: BlueMSGenericMqttConfigurationViewController.PORT_KEY)
        defaults.set(mUserText.text, forKey: BlueMSGenericMqttConfigurationViewController.USER_KEY)
        defaults.set(mClientText.text, forKey: BlueMSGenericMqttConfigurationViewController.CLIENT_ID_KEY)
        defaults.set(mTlsSwtich.isOn, forKey: BlueMSGenericMqttConfigurationViewController.USE_TLS_KEY)
        defaults.synchronize()
    }
    
    private func loadSettings(){
        let defaults = UserDefaults.standard
        mBrokerText.text = defaults.string(forKey: BlueMSGenericMqttConfigurationViewController.BROCKER_KEY)
        mPortText.text = defaults.string(forKey: BlueMSGenericMqttConfigurationViewController.PORT_KEY)
        mUserText.text = defaults.string(forKey: BlueMSGenericMqttConfigurationViewController.USER_KEY)
        mClientText.text = defaults.string(forKey: BlueMSGenericMqttConfigurationViewController.CLIENT_ID_KEY)
        mTlsSwtich.isOn = defaults.bool(forKey: BlueMSGenericMqttConfigurationViewController.USE_TLS_KEY)
        
    }

    private func setTextFieldDelegate(){
        mBrokerText.delegate=self;
        mPortText.delegate=self;
        mUserText.delegate=self;
        mPasswordText.delegate=self;
        mClientText.delegate=self;
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegate()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadSettings()
        if(mClientText.text?.count==0){
            mClientText.text = W2STCloudConfigViewController.getDeviceId(for:self.node);
        }
    }
   
    public override func buildConnectionFactory() -> BlueMSCloudIotConnectionFactory? {
        guard let brockerUrl = mBrokerText.text,
            let port = UInt32(mPortText.text ?? ""),
            let clientId = mClientText.text else{
                return nil
        }
        storeSettings()
        showDetailsButton()
        return BlueMSGenericMqttConnectionFactory(broker: brockerUrl, port: port, user: mUserText.text, password: mPasswordText.text, clientId: clientId, useTls: mTlsSwtich.isOn)
    }
}

extension BlueMSGenericMqttConfigurationViewController : UITextFieldDelegate{
    //hide keyboard when the user press return
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
