//
//  BlueMSCloudConnectionViewController+Strings.swift
//  W2STApp
//
//  Created by Dimitri Giani on 24/03/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit

public extension BlueMSCloudConnectionViewController {
   static let NEW_FW_ALERT_TITLE = {
       return  NSLocalizedString("New Firmware",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "New Firmware",
                                 comment: "New Firmware");
   }();
   
   static let NEW_FW_ALERT_MESSAGE_FORMAT = {
       return  NSLocalizedString("New firmware available.\nUpgrade to %@?",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "New firmware available.\nUpgrade to %@?",
                                 comment: "New firmware available.\nUpgrade to %@?");
   }();
   
   static let NEW_FW_ALERT_YES = {
       return  NSLocalizedString("Yes",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "Yes",
                                 comment: "Yes");
   }();
   
   static let NEW_FW_ALERT_NO = {
       return  NSLocalizedString("No",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "No",
                                 comment: "No");
   }();
   
   static let CONNECTING = {
       return  NSLocalizedString("Connecting...",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "Connecting...",
                                 comment: "Connecting...");
   }();
   
   static let MISSING_PARA_DIALOG_TITLE = {
       return  NSLocalizedString("Error",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "Error",
                                 comment: "Error");
   }();
   
   static let MISSING_PARA_DIALOG_MSG = {
       return  NSLocalizedString("Invalid connection parameters",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "Invalid connection parameters",
                                 comment: "Invalid connection parameters");
   }();
   
   static let DISCONNECT_BUTTON_LABEL = {
       return  NSLocalizedString("Disconnect",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "Disconnect",
                                 comment: "Disconnect");
   }();
   
   static let CONNECT_BUTTON_LABEL = {
       return  NSLocalizedString("Connect",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "Connect",
                                 comment: "Connect");
   }();
   
   static let CONNECTION_ERROR_TITLE = {
       return  NSLocalizedString("Connection Error",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                 value: "Connection Error",
                                 comment: "Connection Error");
   }();
}

