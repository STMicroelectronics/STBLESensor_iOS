//
//  RemoteConfigService.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol RemoteConfigService {
    func fetchAndActivate(completion: @escaping (Bool) -> Void)
    func getString(forKey key: String) -> String
    func getBool(forKey key: String) -> Bool
    func getNumber(forKey key: String) -> NSNumber
    func getAllKeys() -> [String]
}

public struct RemoteConfigVersionRule: Decodable {
    public let dismissionDate: String
}
