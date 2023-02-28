//
//  FilterInterval.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 09/11/2020.
//

import Foundation

public enum FilterInterval: Int, CaseIterable {
    case threeHours
    case sixHours
    case oneDay
    case twoDays
    case sevenDays

    var title: String {
        switch self {
        case .threeHours:
            return "3H"
        case .sixHours:
            return "6H"
        case .oneDay:
            return "1D"
        case .twoDays:
            return "2D"
        case .sevenDays:
            return "7D"
        }
    }
    
    /// Duration in minutes
    var duration: Int {
        switch self {
        case .threeHours:
            return 3*60
        case .sixHours:
            return 6*60
        case .oneDay:
            return 1*24*60
        case .twoDays:
            return 2*24*60
        case .sevenDays:
            return 7*24*60
        }
    }
    
    public var start: Date {
        let calendar = Calendar.current
        
        let date: Date?
        
        switch self {
        case .threeHours:
            date = calendar.date(byAdding: .hour, value: -3, to: Date())
        case .sixHours:
            date = calendar.date(byAdding: .hour, value: -6, to: Date())
        case .oneDay:
            date = calendar.date(byAdding: .day, value: -1, to: Date())
        case .twoDays:
            date = calendar.date(byAdding: .day, value: -2, to: Date())
        case .sevenDays:
            date = calendar.date(byAdding: .day, value: -7, to: Date())
        }
        
        return date ?? Date()
    }
    
    public var end: Date {
        Date()
    }
}
