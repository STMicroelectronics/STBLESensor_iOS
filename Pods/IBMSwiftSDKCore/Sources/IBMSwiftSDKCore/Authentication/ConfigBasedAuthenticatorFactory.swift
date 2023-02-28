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

public enum AuthenticatorError: Error {
    case noConfigurationFound
    case authenticationTypeNotDefined
    case authenticationTypeNotRecognized
    case missingEnvironmentVariable(String)
}

public enum EnvironmentAuthenticatorType: String {
    case IAM = "iam"
    case basic = "basic"
    case CP4D = "cp4d"
    case noAuth = "noauth"
    case bearerToken = "bearertoken"
}

@available (iOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (tvOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (iOSMac, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
@available (watchOS, unavailable, message: "ConfigBasedAuthenticatorFactory is currently available on Linux only.")
public struct ConfigBasedAuthenticatorFactory {
    static public func getAuthenticator(credentialPrefix: String) throws -> Authenticator {
        guard let environmentVariables = CredentialUtils.getEnvironmentVariables(credentialPrefix: credentialPrefix) else {
           throw AuthenticatorError.noConfigurationFound
       }

        let authTypeEnvironmentVariable = environmentVariables[EnvironmentAuthenticatorVariable.authType.rawValue]
            ?? EnvironmentAuthenticatorType.IAM.rawValue

        guard let authenticatorType = EnvironmentAuthenticatorType(rawValue: authTypeEnvironmentVariable.lowercased()) else {
            throw AuthenticatorError.authenticationTypeNotRecognized
        }

        let authenticator = try ConfigBasedAuthenticatorFactory.buildAuthenticator(authenticatorType: authenticatorType, credentials: environmentVariables)
        return authenticator
    }

    static private func buildAuthenticator(authenticatorType: EnvironmentAuthenticatorType, credentials: [String: String]) throws -> Authenticator {
        switch authenticatorType {
        case .basic:
            let basicAuth = try buildBasicAuthenticator(credentials: credentials)
            return basicAuth
        case .CP4D:
            let cp4dAuth = try buildCloudPakForDataAuthenticator(credentials: credentials)
            return cp4dAuth
        case .IAM:
            let iamAuth = try buildIAMAuthenticator(credentials: credentials)
            return iamAuth
        case .bearerToken:
            let tokenAuth = try buildTokenAuthenticator(credentials: credentials)
            return tokenAuth
        case .noAuth:
            let noAuth = NoAuthAuthenticator.init()
            return noAuth
        }
    }

    static private func buildBasicAuthenticator(credentials: [String: String]) throws -> BasicAuthenticator {
        guard let username = credentials[EnvironmentAuthenticatorVariable.username.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.username.rawValue)
        }

        guard let password = credentials[EnvironmentAuthenticatorVariable.password.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.password.rawValue)
        }

        let basicAuthenticator = BasicAuthenticator.init(username: username, password: password)
        return basicAuthenticator
    }

    static private func buildIAMAuthenticator(credentials: [String: String]) throws -> IAMAuthenticator {
        guard let apikey = credentials[EnvironmentAuthenticatorVariable.apiKey.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.apiKey.rawValue)
        }

        let iamAuthenticator = IAMAuthenticator.init(apiKey: apikey)
        return iamAuthenticator
    }

    static private func buildTokenAuthenticator(credentials: [String: String]) throws -> BearerTokenAuthenticator {
        guard let bearerToken = credentials[EnvironmentAuthenticatorVariable.bearerToken.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.bearerToken.rawValue)
        }

        let tokenAuthenticator = BearerTokenAuthenticator.init(bearerToken: bearerToken)
        return tokenAuthenticator
    }

    static private func buildCloudPakForDataAuthenticator(credentials: [String: String]) throws -> CloudPakForDataAuthenticator {
        guard let username = credentials[EnvironmentAuthenticatorVariable.username.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.username.rawValue)
        }

        guard let password = credentials[EnvironmentAuthenticatorVariable.password.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.password.rawValue)
        }

        guard let url = credentials[EnvironmentAuthenticatorVariable.url.rawValue] else {
            throw AuthenticatorError.missingEnvironmentVariable(EnvironmentAuthenticatorVariable.url.rawValue)
        }

        let cp4dAuthenticator = CloudPakForDataAuthenticator.init(username: username, password: password, url: url)
        return cp4dAuthenticator
    }
}
