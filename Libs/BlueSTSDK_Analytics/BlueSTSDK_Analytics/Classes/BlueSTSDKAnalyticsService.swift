//
//  BlueSTSDKAnalyticsService.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 14/05/2018.
//  Copyright © 2018 STMicroelectronics. All rights reserved.
//

import Foundation
import BlueSTSDK
import BlueSTSDK_Gui

public class BlueSTSDKAnalyticsService{
    
    private static let MIN_RUNNING_TIME_S:TimeInterval = 3.0
    
    private var mDemoLog:[String: Date] = [:]
    
    public func startDemo(withName name:String){
        mDemoLog[name] = Date() // now
    }

    public func stopDemo(withName name:String){
        guard let startTime = mDemoLog[name] else {
            //return if no start time
            return
        }
        mDemoLog[name]=nil //remove it
        let duration = -startTime.timeIntervalSinceNow
        if(duration>BlueSTSDKAnalyticsService.MIN_RUNNING_TIME_S){
            recordDemoEvent(BlueSTSDKAnalyticsRunDemoEvent(name: name, duration: duration))
        }
    }
    
    
    private var mReadVersionConsole: BlueSTSDKFwReadVersionConsole?;
    
    public func recordConnection(with node:BlueSTSDKNode,fwVersion version:BlueSTSDKFwVersion){
        recordConnectionEvent(BlueSTSDKAnalyticsConnectionEvent(node: node, version: version))
    }
    
    public func recordConnection(with node:BlueSTSDKNode){
        mReadVersionConsole = BlueSTSDKFwConsoleUtil.getFwReadVersionConsoleForNode(node: node)
        if let console = mReadVersionConsole{
            let sendCmd = console.readFwVersion{ version in
                self.recordConnectionEvent(BlueSTSDKAnalyticsConnectionEvent(node: node, version: version))
            }
            if(!sendCmd){ // if we can't send the command log whotut the fw info
                recordConnectionEvent(BlueSTSDKAnalyticsConnectionEvent(node: node, version: nil))
            }
        }else{
            recordConnectionEvent(BlueSTSDKAnalyticsConnectionEvent(node: node, version: nil))
        }
    }
    
    open func recordDemoEvent(_ event:BlueSTSDKAnalyticsRunDemoEvent){}

    open func recordConnectionEvent(_ event:BlueSTSDKAnalyticsConnectionEvent){}
    
}
