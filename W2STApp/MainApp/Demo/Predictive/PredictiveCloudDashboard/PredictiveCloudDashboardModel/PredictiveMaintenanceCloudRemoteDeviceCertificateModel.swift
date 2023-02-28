//
//  PredictiveMaintenanceCloudRemoteDeviceCertificateModel.swift
//  W2STApp

import Foundation

/** Decode Certificate JSON from POST add new device */
public struct CertificateResponse: Codable {
    public let certificateArn: String
    public let certificateId: String
    public let certificatePem: String
    public let keyPair: CertificateKeys

    enum CodingKeys: String, CodingKey {
        case certificateArn = "certificateArn"
        case certificateId = "certificateId"
        case certificatePem = "certificatePem"
        case keyPair = "keyPair"
    }

    public init(certificateArn: String, certificateId: String, certificatePem: String, keyPair: CertificateKeys) {
        self.certificateArn = certificateArn
        self.certificateId = certificateId
        self.certificatePem = certificatePem
        self.keyPair = keyPair
    }
}

public struct CertificateKeys: Codable {
    public let publicKey: String
    public let privateKey: String

    enum CodingKeys: String, CodingKey {
        case publicKey = "PublicKey"
        case privateKey = "PrivateKey"
    }

    public init(publicKey: String, privateKey: String) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
}
