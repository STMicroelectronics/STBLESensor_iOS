//
//  Date+Extensions.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 28/04/21.
//

import Foundation

public extension Date {
    var nowDateFormattedForBoard: String {
        let df = DateFormatter()
        df.dateFormat = "ee"
        df.locale = Locale(identifier: "IT-it")
        let weekDay = Int(df.string(from: self)) ?? 0

        df.dateFormat = "dd/MM/YY"
        let dateString = df.string(from: self)

        return "\(String(format: "%02d", weekDay))/\(dateString)"
    }
    
    var nowTimeFormattedForBoard: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "IT-it")
        df.dateFormat = "HH:mm:ss"
        
        return df.string(from: self)
    }
}
