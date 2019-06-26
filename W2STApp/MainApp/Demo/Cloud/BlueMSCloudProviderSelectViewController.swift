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

import Foundation

fileprivate struct CloudProvider{
    public let name:String
    public let segue:String
    
    init(name:String, segue:String) {
        self.name=name;
        self.segue = segue;
    }
}

class BlueMSCloudProviderSelectViewController : BlueMSDemoTabViewController,
BlueMSCloudLogSelectUpdateTimeDelegate, UITableViewDataSource, UITableViewDelegate{
    
    private static let UPDATE_INTERVAL_KEY = "BlueMSCloudProviderSelectViewController.UPDATE_INTERVAL_KEY"
    private static let DEFAULT_UPDATE_INTERVAL = TimeInterval(5.0)
    
    private static let CELL_TABLE_IDENTIFIER = "CloudProviderName"
    private static let CLOUD_PROVIDERS:[CloudProvider] = {
        let bundle = Bundle(for: BlueMSCloudProviderSelectViewController.self)
        return [
        CloudProvider(name:
            NSLocalizedString("Azure IoT Central - Contoso", tableName: nil, bundle: bundle,
                              value: "Azure IoT Central - Contoso", comment: ""),
                      segue:"azureIoTCentral_segue"),
        CloudProvider(name:
            NSLocalizedString("Azure IoT", tableName: nil, bundle: bundle,
                              value: "Azure IoT", comment: ""),
                      segue:"AzureIot_segue"),
        CloudProvider(name:
            NSLocalizedString("Aws IoT", tableName: nil, bundle: bundle,
                              value: "Aws IoT", comment: ""),
                      segue:"AwsIoT_Segue"),
        CloudProvider(name:
            NSLocalizedString("IBM Watson IoT - Quickstart", tableName: nil, bundle: bundle,
                              value: "IBM Watson IoT - Quickstart", comment: ""),
                      segue:"BlueMxQuickStart_segue"),
        CloudProvider(name:
            NSLocalizedString("IBM Watson IoT", tableName: nil, bundle: bundle,
                              value: "IBM Watson IoT", comment: ""),
                      segue:"BlueMx_segue"),
        CloudProvider(name:
            NSLocalizedString("Generic MQTT", tableName: nil, bundle: bundle,
                              value: "Generic MQTT", comment: ""),
                      segue:"GenericMqtt_segue")
        ]}()
    
    @IBOutlet weak var mCloudProviderList: UITableView!
    
    @IBOutlet weak var mUpdateIntervalValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mCloudProviderList.dataSource=self;
        mCloudProviderList.delegate=self;
        mCloudProviderList.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayUpdateInterval(updateInterval: getTimeInterval())
    }
    
    private func displayUpdateInterval(updateInterval:TimeInterval){
        mUpdateIntervalValue.text = String(format: "%.1f s",updateInterval)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cloudConfig = segue.destination as? W2STCloudConfigViewController{
            cloudConfig.node=self.node;
            cloudConfig.minUpdateInterval = getTimeInterval()
        }
        if let selectInterval = segue.destination as? BlueMSCloudLogSelectUpdateTimeViewController{
            selectInterval.delegate = self;
            selectInterval.currentUpdateInterval = getTimeInterval()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BlueMSCloudProviderSelectViewController.CLOUD_PROVIDERS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BlueMSCloudProviderSelectViewController.CELL_TABLE_IDENTIFIER)
        cell?.textLabel?.text = BlueMSCloudProviderSelectViewController.CLOUD_PROVIDERS[indexPath.row].name
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier:BlueMSCloudProviderSelectViewController.CLOUD_PROVIDERS[indexPath.row].segue,
                     sender: self)
    }
    
    func onUpdateTimeSelected(updateTime: TimeInterval) {
        storeTimeInterval(interval: updateTime)
        displayUpdateInterval(updateInterval: updateTime)
    }
    
    private func getTimeInterval()->TimeInterval{
        let userPref = UserDefaults.standard;
        if(userPref.object(forKey: BlueMSCloudProviderSelectViewController.UPDATE_INTERVAL_KEY) != nil){
            return userPref.double(forKey: BlueMSCloudProviderSelectViewController.UPDATE_INTERVAL_KEY)
        }else{
            return BlueMSCloudProviderSelectViewController.DEFAULT_UPDATE_INTERVAL
        }
    }
    
    private func storeTimeInterval(interval:TimeInterval){
        let userPref = UserDefaults.standard;
        userPref.set(Double(interval), forKey: BlueMSCloudProviderSelectViewController.UPDATE_INTERVAL_KEY)
    }
    
}
