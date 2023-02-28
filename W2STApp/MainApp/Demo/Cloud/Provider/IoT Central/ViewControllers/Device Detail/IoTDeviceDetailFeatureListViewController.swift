//
//  IoTDeviceDetailFeatureListViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

class IoTDeviceDetailFeatureListViewController: BlueMSCloudConnectionViewController {
    var didUpdateSample: (BlueSTSDKFeature, BlueSTSDKFeatureSample) -> Void = { _, _ in }
    var samples: [Any] = []
    var session: AzureIotCentralClient?
    
    static let dtmiNameOfBLEFeatures = IotCentralConnectionFactory.dtmiNameOfBLEFeatures
    
    var telemetryValueHandler: ((String, String) -> ())?
    
    override func viewDidLoad() {
        mFeatureList = UITableView(frame: .zero, style: .grouped)
        mConnectionFactory = connectionFactoryBuilder.buildConnectionFactory()
        mFeatureList?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        mFeatureList?.backgroundColor = .white
        mFeatureList?.backgroundView?.backgroundColor = .white
        mFeatureList?.allowsSelection = false
        
        super.viewDidLoad()
        
        view.addSubviewAndFit(mFeatureList!)
        mFeatureList?.isHidden = true
    }
    
    func connect(_ completion: @escaping (Bool) -> Void) {
        if let session = mConnectionFactory?.getSession() as? AzureIotCentralClient {
            self.session = session
            
            session.connect { [weak self] error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if error == nil {
                        self.mFeatureListener = self.mConnectionFactory?.getFeatureDelegate(withSession: session, minUpdateInterval: self.minUpdateInterval)
                        (self.mFeatureListener as? IotCentralFeatureListener)?.didUpdateSample = { [weak self] device, feature, sample in

                            /** Find dtmi_name of feature and use it to upload data */
                            let name = IoTDeviceDetailFeatureListViewController.dtmiNameOfBLEFeatures.findKey(forValue: feature)
                            guard let dtmiName = name else { return }
                            
                            self?.telemetryValueHandler?(feature.name, feature.description())
                            
                            self?.didUpdateSample(feature, sample)
                            self?.manageSampleUpdate(device: device, feature: feature, sample: sample, dtmiName: dtmiName)
                        }
                        self.mEnabledFeature = self.extractEnabledFeature()
                        self.mFeatureList?.isHidden = false
                        self.mFeatureList?.reloadData()
                        
                        completion(true)
                    } else {
                        self.session = nil
                        
                        completion(false)
                    }
                }
            }
        }
    }
    
    func disconnect() {
        disableAllNotification()
        session?.disconnect(nil)
        session = nil
        mEnabledFeature.removeAll()
        mFeatureList?.isHidden = true
    }
    
    private func manageSampleUpdate(device: IoTDevice, feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample, dtmiName: String) {
        guard   session?.isConnected == true,
                let json = IoTDevice.json(device: device, feature, sample: sample, dtmiFeatureName: dtmiName),
                let jsonString = json.rawString() else { return }
        
        if session?.sendTelemetryData(messageStr: jsonString, component: "std_comp") == false {
            self.telemetryValueHandler?("ERROR", "Network Request Failed. Please check your connectivity.")
        }
    }
}
