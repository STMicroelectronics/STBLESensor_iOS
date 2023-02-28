//
//  BankStatusResponseModel.swift
//  BlueSTSDK

import Foundation

public struct BankStatusResponse: Codable {
    public let currentBank: Int
    public let fwId1: String
    public let fwId2: String

    enum CodingKeys: String, CodingKey {
        case currentBank, fwId1, fwId2
    }
 }
