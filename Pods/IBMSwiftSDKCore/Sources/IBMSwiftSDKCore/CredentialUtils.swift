/**
 * Copyright IBM Corporation 2019
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum EnvironmentAuthenticatorVariable: String {
    case authType = "auth_type"
    case username = "username"
    case password = "password"
    case apiKey = "apikey"
    case bearerToken = "bearer_token"
    case url = "auth_url"
    case serviceURL = "service_url"
    case disableSSL = "auth_disable_ssl"
}

@available (iOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (tvOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (iOSMac, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (watchOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
public struct CredentialUtils {
    @available(iOS 9.0, *)
    static public func getEnvironmentVariables(credentialPrefix: String) -> [String: String]? {
        let formattedCredentialPrefix: String = credentialPrefix.uppercased()

        // look in user defined filepath for .env file
        if let userDefinedEnvFileName: String = ProcessInfo.processInfo.environment["IBM_CREDENTIALS_FILE"] {
            if FileManager.default.fileExists(atPath: userDefinedEnvFileName) && FileManager.default.isReadableFile(atPath: userDefinedEnvFileName) {
                let userDefinedEnvFile: URL = URL.init(fileURLWithPath: userDefinedEnvFileName)
                if let userSpecifiedEnvironmentVariables: [String: String] = CredentialUtils.readEnvironmentFile(filePath: userDefinedEnvFile, credentialPrefix: formattedCredentialPrefix) {
                    return userSpecifiedEnvironmentVariables
                }
            }
        }

        // look in the current working directory for a .env file
        let localEnvFile: URL = URL.init(fileURLWithPath: "ibm-credentials.env")
        if let localEnvironmentVariables: [String: String] = CredentialUtils.readEnvironmentFile(filePath: localEnvFile, credentialPrefix: formattedCredentialPrefix) {
            return localEnvironmentVariables
        }

        // look in the home directory for .env file
        let homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
        let homeDirectoryEnvFile: URL = URL.init(fileURLWithPath: "ibm-credentials.env", relativeTo: homeDirectory)
        if let homeDirectoryEnvironmentVariables: [String: String] = CredentialUtils.readEnvironmentFile(filePath: homeDirectoryEnvFile, credentialPrefix: formattedCredentialPrefix) {
            return homeDirectoryEnvironmentVariables
        }

        // look in VCAP_SERVICES (only available in CF environment)
        if let vcapServicesEnvironmentVariables: [String: String] = CredentialUtils.readVCAPServicesVariables(credentialPrefix: credentialPrefix) {
            return vcapServicesEnvironmentVariables
        }

        return nil
    }

    @available(iOS 9.0, *)
    static public func getServiceURL(credentialPrefix: String) -> String? {
        guard let credentials = CredentialUtils.getEnvironmentVariables(credentialPrefix: credentialPrefix) else {
            return nil
        }

        guard let serviceURL = credentials[EnvironmentAuthenticatorVariable.serviceURL.rawValue] else {
            return nil
        }

        return serviceURL
    }

    static public func getDisableSSLConfig(credentialPrefix: String) -> Bool {
        guard let credentials = CredentialUtils.getEnvironmentVariables(credentialPrefix: credentialPrefix) else {
            return false
        }

        guard let disableSSL = credentials[EnvironmentAuthenticatorVariable.disableSSL.rawValue] else {
            return false
        }

        let disableSSLValue: Bool = (disableSSL == "true") ? true : false
        return disableSSLValue
    }

    static private func extractEnvironmentVariablesFromFile(environmentVariablePrefix: String, file: URL) -> [String: String]? {
        guard let fileLines = try? String(contentsOf: file).components(separatedBy: .newlines) else {
            return nil
        }

        // Turn each credential into a key/value pair
        let serviceCredentials = fileLines
            .filter { $0.uppercased().starts(with: environmentVariablePrefix.uppercased()) }
            .reduce([:]) { (result, credentialLine) -> [String: String] in
                let credentials = credentialLine.split(separator: "=", maxSplits: 1)
                let lowerCaseKey = credentials[0].lowercased().replacingOccurrences(of: "-", with: "_")
                let removalIndex = lowerCaseKey.index(lowerCaseKey.startIndex, offsetBy: environmentVariablePrefix.count + 1)
                let key = String(lowerCaseKey[removalIndex...])
                let value = String(credentials[1])

                return result.merging([key: value]) { (_, new) in new }
        }
        return serviceCredentials
    }

   static private func readEnvironmentFile(filePath: URL, credentialPrefix: String) -> [String: String]? {
        let environmentVariables: [String: String]? = CredentialUtils.extractEnvironmentVariablesFromFile(environmentVariablePrefix: credentialPrefix, file: filePath)
        return environmentVariables
    }

    static private func readVCAPServicesVariables(credentialPrefix: String) -> [String: String]? {
        guard let vcapServicesEnvironmentVariable = ProcessInfo.processInfo.environment["VCAP_SERVICES"] else {
            return nil
        }

        let jsonData = try? JSONSerialization.jsonObject(with: vcapServicesEnvironmentVariable.data(using: .utf8)!, options: [])

        guard let parsedJsonData = jsonData as? [String: Any] else {
            return nil
        }

        if let selectedService = parsedJsonData[credentialPrefix] as? [Any] {
            if let firstServiceObject = selectedService.first as? [String: Any] {
                if let serviceCredentials = firstServiceObject["credentials"] as? [String: String] {
                    guard let authType = inferAuthType(credentials: serviceCredentials) else {
                        return nil
                    }

                    var updatedServiceCredentials = serviceCredentials
                    updatedServiceCredentials["auth_type"] = authType
                    return updatedServiceCredentials
                }
            }
        }

        return nil
    }

    static private func inferAuthType(credentials: [String: String]) -> String? {
        if credentials["apikey"] != nil || credentials["iam_apikey"] != nil {
            return EnvironmentAuthenticatorType.IAM.rawValue
        }

        if credentials["username"] != nil && credentials["password"] != nil {
            return EnvironmentAuthenticatorType.basic.rawValue
        }

        return nil
    }
}
