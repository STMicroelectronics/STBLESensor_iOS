//
//  PredictiveMaintenanceCloudRemoteDeviceModel.swift
//  W2STApp

import Foundation


/** Decode JSON from GET device List */
public struct PMResponse: Codable {
    public let things: [PMRemoteDevices]?
    public let nextToken: String?

    enum CodingKeys: String, CodingKey {
        case things = "things"
        case nextToken = "nextToken"
    }

    public init(things: [PMRemoteDevices]?, nextToken: String?) {
        self.things = things
        self.nextToken = nextToken
    }
}

public struct PMRemoteDevices: Codable {
    public let thingName: String?
    public let thingTypeName: String?
    public let thingArn: String?
    public let attributes: PMRemoteAttributes?
    public let version: Int?

    enum CodingKeys: String, CodingKey {
        case thingName = "thingName"
        case thingTypeName = "thingTypeName"
        case thingArn = "thingArn"
        case attributes = "attributes"
        case version = "version"
    }

    public init(thingName: String?, thingTypeName: String?, thingArn: String?, attributes: PMRemoteAttributes?, version: Int?) {
        self.thingName = thingName
        self.thingTypeName = thingTypeName
        self.thingArn = thingArn
        self.attributes = attributes
        self.version = version
    }
}

public struct PMRemoteAttributes: Codable {
    public let assetname: String?
    public let fab: String?
    public let group: String?
    public let owner: String?

    enum CodingKeys: String, CodingKey {
        case assetname = "assetname"
        case fab = "fab"
        case group = "group"
        case owner = "owner"
    }

    public init(assetname: String?, fab: String?, group: String?, owner: String?) {
        self.assetname = assetname
        self.fab = fab
        self.group = group
        self.owner = owner
    }
}
