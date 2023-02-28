//
//  UIViewController+demoName.swift
//  W2STApp
//
//  Created by Giovanni Visentini on 08/09/2017.
//  Copyright © 2017 STMicroelectronics. All rights reserved.
//

import Foundation

public extension UIViewController{
    
    /// return the demo name to use for the analytics event
    /// it use the barItem title, or the view controller title
    /// - Returns: demo name to use for the analytics event
    private func getDemoName()->String?{
        return self.tabBarItem.title ?? self.title;
    }
    
    /// return the analytics service to use
    ///
    /// - Returns: analytics service
    private func getAnalytics() -> BlueSTSDKAnalyticsService?{
        return (UIApplication.shared.delegate as? BlueSTSDKAppWithAnalytics)?.analytics
    }
    
    /// record the start demo event
    @objc //to use it in the BlueMSDemoTabViewControllerWithAnalytics
    func recordStartDemo(){
        if let name = getDemoName(){
            getAnalytics()?.startDemo(withName: name);
            //(UIApplication.shared.delegate as? BlueSTSDKAppWithAnalytics)?.analytics?.startDemo(withName: name);
        }
    }
        
    /// record the stop demo event
    @objc //to use it in the BlueMSDemoTabViewControllerWithAnalytics
    func recordStopDemo(){
        if let name = getDemoName(){
            getAnalytics()?.stopDemo(withName: name);
            //(UIApplication.shared.delegate as? BlueSTSDKAppWithAnalytics)?.analytics?.stopDemo(withName: name);
        }
    }
}
