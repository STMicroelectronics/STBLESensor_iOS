//
//  DateFormatter.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 16/11/20.
//

import Foundation

public extension DateFormatter {
    static let full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss - dd/MM"
        return formatter;
    }();
    
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd/MM"
        return formatter;
    }();
    
    static let dayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter;
    }();
    
    static let hour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter;
    }();
}
