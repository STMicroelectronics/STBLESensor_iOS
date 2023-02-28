//
//  HSDDeviceParser.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 27/01/21.
//

import Foundation

public class HSDDeviceParser {
    static func responseFrom(data: Data) -> HSDResponse? {
        var finalData = data
        finalData.removeLast()
        let string = String(data: finalData, encoding: .utf8)
        do {
            return try JSONDecoder().decode(HSDResponse.self, from: finalData)
        } catch {
//            debugPrint("Device Response decode error: \(error)")
            return nil
        }
    }
    
    static func deviceStatusFrom(data: Data) -> HSDDeviceStatus? {
        var finalData = data
        finalData.removeLast()
        let string = String(data: finalData, encoding: .utf8)
        do {
            return try JSONDecoder().decode(HSDDeviceStatus.self, from: finalData)
        } catch {
//            debugPrint("Device Status decode error: \(error)")
            return nil
        }
    }
    
    static func tagConfigFrom(data: Data) -> HSDTagConfigContainer? {
        var finalData = data
        finalData.removeLast()
        let string = String(data: finalData, encoding: .utf8)
        do {
            return try JSONDecoder().decode(HSDTagConfigContainer.self, from: finalData)
        } catch {
//            debugPrint("TAG Config decode error: \(error)")
            return nil
        }
    }
}
