//
//  Data.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 04/11/2020.
//

extension Data {
    var prettyJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
