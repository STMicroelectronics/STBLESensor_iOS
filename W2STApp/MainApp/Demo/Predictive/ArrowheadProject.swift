//
//  ArrowheadProject.swift
//  W2STApp

import Foundation

let arrowheadGETUrl : String = "http://137.204.57.93:8443/serviceregistry/mgmt/systems/877"

public struct ArrowheadResponseTemplate: Codable {
    public let id: Int
    public let systemName: String
    public let address: String
    public let port: Int
    public let createdAt: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case systemName = "systemName"
        case address = "address"
        case port = "port"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }

    public init(id: Int, systemName: String, address: String, port: Int, createdAt: String?, updatedAt: String?) {
        self.id = id
        self.systemName = systemName
        self.address = address
        self.port = port
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
