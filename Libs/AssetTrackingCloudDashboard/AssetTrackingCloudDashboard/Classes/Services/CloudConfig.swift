//
//  CloudConfig.swift
//  SmarTagCloudAssetTracking
//
//  Created by Giovanni Visentini on 29/08/2019.
//  Copyright © 2019 Giovanni Visentini. All rights reserved.
//

import Foundation

public class CloudConfig {
    public static let loginManager: LoginManager = { AppAuthLoginManager() }()
}
