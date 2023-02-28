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

import UIKit

class BlueMSCloudProviderSelectViewController : BlueMSDemoTabViewController, BlueMSCloudLogSelectUpdateTimeDelegate {
    enum CloudProvider {
        case azure_iot
        case azure_iot_central_sensortile
        case azure_iot_central
        case azure_iot_web_dashboard
        //case ibm_iot_quickstart
        //case ibm_iot
        case aws
        case mqtt
        case assetTracking
        
        var title: String {
            switch self {
                case .azure_iot: return "Azure IoT".localizedFromGUI
                case .azure_iot_central_sensortile: return "Azure IoT Central - SensorTile.box".localizedFromGUI
                case .azure_iot_central: return "Azure IoT Central".localizedFromGUI
                case .azure_iot_web_dashboard: return "Azure IoT - ST Web Dashboard".localizedFromGUI
                //case .ibm_iot_quickstart: return "IBM Watson IoT - Quickstart".localizedFromGUI
                //case .ibm_iot: return "IBM Watson IoT".localizedFromGUI
                case .aws: return "Aws IoT".localizedFromGUI
                case .mqtt: return "Generic MQTT".localizedFromGUI
                case .assetTracking: return "ST Asset-Tracking".localizedFromGUI
            }
        }
        
        @discardableResult
        func showMainController(from viewController: UIViewController) -> UIViewController? {
            switch self {
                case .azure_iot:
                    viewController.performSegue(withIdentifier: "AzureIot_segue", sender: viewController)
                    return nil
                case .azure_iot_central_sensortile:
                    viewController.performSegue(withIdentifier: "azureIoTCentral_segue", sender: viewController)
                    return nil
                case .azure_iot_central:
                    let controller = IoTCentralAppsViewController()
                    viewController.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
                   //viewController.navigationController?.pushViewController(controller, animated: true)
                    return controller
                    
                case .azure_iot_web_dashboard:
                    viewController.performSegue(withIdentifier: "STAzureDashboard_segue", sender: viewController)
                    return nil
                /*case .ibm_iot_quickstart:
                    viewController.performSegue(withIdentifier: "BlueMxQuickStart_segue", sender: viewController)
                    return nil
                case .ibm_iot:
                    viewController.performSegue(withIdentifier: "BlueMx_segue", sender: viewController)
                    return nil*/
                case .aws:
                    viewController.performSegue(withIdentifier: "AwsIoT_Segue", sender: viewController)
                    return nil
                case .mqtt:
                    viewController.performSegue(withIdentifier: "GenericMqtt_segue", sender: viewController)
                    return nil
                case .assetTracking:
                    let controller = STATCloudLoggingViewController()
                    viewController.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
                    //viewController.navigationController?.pushViewController(controller, animated: true)
                    return controller
            }
        }
    }

    private static let UPDATE_INTERVAL_KEY = "BlueMSCloudProviderSelectViewController.UPDATE_INTERVAL_KEY"
    private static let DEFAULT_UPDATE_INTERVAL: TimeInterval = 5
    
    @IBOutlet weak var mCloudProviderList: UITableView?
    @IBOutlet weak var mUpdateIntervalValue: UILabel?
    
    //private let model: [CloudProvider] = [.azure_iot, .azure_iot_central, .aws, .ibm_iot_quickstart, .mqtt, .assetTracking]
    private let model: [CloudProvider] = [.azure_iot, .azure_iot_central, .aws, .mqtt, .assetTracking]
    private var timeInterval: TimeInterval {
        get {
            UserDefaults.standard.value(forKey: BlueMSCloudProviderSelectViewController.UPDATE_INTERVAL_KEY) as? TimeInterval ?? BlueMSCloudProviderSelectViewController.DEFAULT_UPDATE_INTERVAL
        }
        set {
            let ud = UserDefaults.standard
            ud.set(newValue, forKey: BlueMSCloudProviderSelectViewController.UPDATE_INTERVAL_KEY)
            ud.synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mCloudProviderList?.dataSource = self
        mCloudProviderList?.delegate = self
        mCloudProviderList?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayUpdateInterval(updateInterval: timeInterval)
    }
    
    private func displayUpdateInterval(updateInterval: TimeInterval) {
        mUpdateIntervalValue?.text = String(format: "%.1f s", updateInterval)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cloudConfig = segue.destination as? W2STCloudConfigViewController {
            setupCloudController(cloudConfig, withNode: node, timeInterval: timeInterval)
        } else if let selectInterval = segue.destination as? BlueMSCloudLogSelectUpdateTimeViewController {
            selectInterval.delegate = self
            selectInterval.currentUpdateInterval = timeInterval
        }
    }
    
    internal func onUpdateTimeSelected(updateTime: TimeInterval) {
        timeInterval = updateTime
        displayUpdateInterval(updateInterval: updateTime)
    }
    
    internal func setupCloudController(_ controller: W2STCloudConfigViewController, withNode node: BlueSTSDKNode, timeInterval: TimeInterval) {
        controller.node = node
        controller.minUpdateInterval = timeInterval
    }
}

extension BlueMSCloudProviderSelectViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CloudProviderName", for: indexPath)
        cell.textLabel?.text = model[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let controller = model[indexPath.row].showMainController(from: self) as? W2STCloudConfigViewController {
            setupCloudController(controller, withNode: node, timeInterval: timeInterval)
        }
    }
}
