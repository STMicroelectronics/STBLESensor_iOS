//
//  BlueSTSDKAnalyticsRunDemoEvent.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 17/01/2018.
//  Copyright © 2018 STMicroelectronics. All rights reserved.
//

import Foundation

public class BlueSTSDKAnalyticsRunDemoEvent : NSObject{
    
    public static let EVENT_NAME = "Demo"
    public static let DEMO_NAME_KEY = "Name"
    public static let DURATION_KEY = "Duration"
 
    public let demoName:String
    public let duration:TimeInterval
    
    init(name:String, duration:TimeInterval){
        demoName = name;
        self.duration = duration
    }
}
