//
//  DIL24Utilities.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import STBlueSDK
import STCore

private func getCurrentFirmware(node: Node) -> Firmware? {
    guard node.protocolVersion == 0x02 else { return nil }
    guard let catalogService: CatalogService = Resolver.shared.resolve(),
          let catalog = catalogService.catalog else { return nil }
    guard let firmware = catalog.v2Firmware(with: node.deviceId.longHex,
                                            firmwareId: UInt32(node.bleFirmwareVersion).longHex) else { return nil }
    return firmware
}

public func searchForMountedDIL24(node: Node) -> [String]? {
    guard let firmware = getCurrentFirmware(node: node) else { return nil }
    guard let optionBytesMessages = node.getOptionBytesMessagesForBoxProFlow(with: firmware) else {  return nil }
    guard let sensorsMounted = optionBytesMessages.first else { return nil }
    return extractSensorNames(from: sensorsMounted)
}

public func searchForLoadedApp(node: Node) -> String? {
    guard let firmware = getCurrentFirmware(node: node) else { return nil }
    guard let optionBytesMessages = node.getOptionBytesMessagesForBoxProFlow(with: firmware) else {  return nil }
    guard let optMessagesLoadedApps = optionBytesMessages.last else { return nil }
    let loadedApps = extractSensorNames(from: optMessagesLoadedApps)
    if loadedApps.count > 1 {
        var outputLoadedApps: String = ""
        loadedApps.forEach { loadedApp in
            outputLoadedApps += loadedApp + " "
        }
        return outputLoadedApps
    } else {
        guard let loadedApp = loadedApps.first else { return nil }
        return loadedApp
    }
}

public func searchForExtraExamplesFlow(node: Node) -> [ExtraExampleFlow]? {
    guard let firmware = getCurrentFirmware(node: node) else { return nil }
    return firmware.extraExamplesFlow
}

public func isDIL24Mounted(_ sensorsMountedList: [String]?, _ flowSensorItem: Sensor) -> Bool {
    guard let sensorsMountedList = sensorsMountedList else { return false }
    guard !sensorsMountedList.isEmpty else { return false }
    let isMounted = sensorsMountedList.first(where: { $0 == flowSensorItem.model })
    guard isMounted != nil else { return false }
    return true
}

public func extractSensorNames(from input: String) -> [String] {
    return input
        .split(separator: "/")
        .map { $0.trimmingCharacters(in: .whitespaces) }
}
