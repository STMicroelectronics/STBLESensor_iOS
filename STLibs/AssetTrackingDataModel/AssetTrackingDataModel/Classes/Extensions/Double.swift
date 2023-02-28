//
//  Double.swift
//  TrackerThresholdUtil
//
//  Created by Klaus Lanzarini on 16/11/20.
//

import Foundation

public extension Double {
    public var date: Date {
        return Date.init(timeIntervalSince1970: self / 1000)
    }
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
