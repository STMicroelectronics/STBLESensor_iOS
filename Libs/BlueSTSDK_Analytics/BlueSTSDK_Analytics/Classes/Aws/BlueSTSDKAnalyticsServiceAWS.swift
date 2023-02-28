//
//  BlueSTSDKAnalyticsServiceAWS.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 17/01/2018.
//  Copyright © 2018 STMicroelectronics. All rights reserved.
//

import Foundation

import AWSPinpoint

public class BlueSTSDKAnalyticsServiceAWS : BlueSTSDKAnalyticsService{
    
    private let pinpointAnalyticsClient:AWSPinpointAnalyticsClient;
    
    public override init(){
        pinpointAnalyticsClient = AWSPinpoint(configuration:
            AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: nil)).analyticsClient
    }
    
    override public func recordDemoEvent(_ demoEvent: BlueSTSDKAnalyticsRunDemoEvent) {
        DispatchQueue.main.async {
            let event = self.pinpointAnalyticsClient.createEvent(withEventType: BlueSTSDKAnalyticsRunDemoEvent.EVENT_NAME)
            event.addAttribute(demoEvent.demoName, forKey: BlueSTSDKAnalyticsRunDemoEvent.DEMO_NAME_KEY)
            event.addMetric(NSNumber(value: demoEvent.duration), forKey: BlueSTSDKAnalyticsRunDemoEvent.DURATION_KEY)
            
            self.pinpointAnalyticsClient.record(event).continueOnSuccessWith{
                _ in
                self.pinpointAnalyticsClient.submitEvents()
            }
            
        } // dispatch async
    }
    
    override public func recordConnectionEvent(_ connectionEvent: BlueSTSDKAnalyticsConnectionEvent) {
        DispatchQueue.main.async {
            let event = self.pinpointAnalyticsClient.createEvent(withEventType: BlueSTSDKAnalyticsConnectionEvent.EVENT_NAME)
            event.addAttribute(connectionEvent.nodeName, forKey: BlueSTSDKAnalyticsConnectionEvent.NAME_KEY)
            event.addAttribute(connectionEvent.address, forKey: BlueSTSDKAnalyticsConnectionEvent.ADDRESS_KEY)
            event.addAttribute(connectionEvent.type, forKey: BlueSTSDKAnalyticsConnectionEvent.BOARD_TYPE_NAME_KEY)
            event.addAttribute(connectionEvent.typeId, forKey: BlueSTSDKAnalyticsConnectionEvent.BOARD_TYPE_ID_KEY)
            event.addAttribute(connectionEvent.fwName, forKey: BlueSTSDKAnalyticsConnectionEvent.FW_NAME_KEY)
            event.addAttribute(connectionEvent.fwVersion, forKey: BlueSTSDKAnalyticsConnectionEvent.FW_VERSION_KEY)
            event.addAttribute(connectionEvent.appName, forKey: BlueSTSDKAnalyticsConnectionEvent.APP_NAME_KEY)
            event.addAttribute(connectionEvent.appVersion, forKey: BlueSTSDKAnalyticsConnectionEvent.APP_VERSION_KEY)
            
            self.pinpointAnalyticsClient.record(event).continueOnSuccessWith{
                _ in
                self.pinpointAnalyticsClient.submitEvents()
            }
        } // dispatch async
    }
        
}
