//
//  STATFeatureListViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 30/03/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import AssetTrackingDataModel
import UIKit

class STATFeatureListViewController: BlueMSCloudConnectionViewController {
    var didUpdateSamples: () -> Void = {}
    var canAddSamples: Bool {
        get {
            (mFeatureListener as? BlueMSCloudIotSTAssetTrackingFeatureListener)?.canAddSamples ?? false
        }
        set {
            (mFeatureListener as? BlueMSCloudIotSTAssetTrackingFeatureListener)?.canAddSamples = newValue
        }
    }
    
    var samples: [DataSample] {
        (mFeatureListener as? BlueMSCloudIotSTAssetTrackingFeatureListener)?.samples ?? []
    }
    
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
    
    func removeAllSamples() {
        (mFeatureListener as? BlueMSCloudIotSTAssetTrackingFeatureListener)?.samples = []
    }
    
    func connect() {
        if let session = mConnectionFactory?.getSession() {
            mFeatureListener = mConnectionFactory?.getFeatureDelegate(withSession: session, minUpdateInterval: minUpdateInterval)
            (mFeatureListener as? BlueMSCloudIotSTAssetTrackingFeatureListener)?.didUpdateSamples = { [weak self] in
                self?.didUpdateSamples()
            }
            mEnabledFeature = extractEnabledFeature()
        }
        
        mFeatureList?.isHidden = false
        mFeatureList?.reloadData()
    }
    
    func disconnect() {
        disableAllNotification()
        mEnabledFeature.removeAll()
        mFeatureList?.isHidden = true
    }
}
