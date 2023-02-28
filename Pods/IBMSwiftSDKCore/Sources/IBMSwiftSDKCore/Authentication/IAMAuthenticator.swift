/**
 * Copyright IBM Corporation 2018, 2019
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

/** Authenticate with an IAM API key. The API key is used to automatically retrieve and refresh access tokens. */
public class IAMAuthenticator: TokenSourceAuthenticator {

    public init(apiKey: String, url: String? = nil) {
        super.init(tokenSource: IAMTokenSource(apiKey: apiKey, url: url))
    }

    public func setClientCredentials(clientID: String, clientSecret: String) {
        if let tokenSource = self.tokenSource as? IAMTokenSource {
            tokenSource.setClientCredentials(clientID: clientID, clientSecret: clientSecret)
        }
    }
}

class IAMTokenSource: TokenSource {

    let url: String

    var headers: [String: String]?

    var session = URLSession(configuration: URLSessionConfiguration.default)

    private let apiKey: String
    private var token: String?
    private var refreshDate: Date?
    private var clientAuthenticator: Authenticator = NoAuthAuthenticator()

    init(apiKey: String, url: String? = nil) {
        self.apiKey = apiKey
        if let url = url {
            self.url = url
        } else {
            self.url = "https://iam.cloud.ibm.com/identity/token"
        }
    }

    #if !os(Linux)
    /**
     Allow network requests to a server without verification of the server certificate.
     **IMPORTANT**: This should ONLY be used if truly intended, as it is unsafe otherwise.
     */
    func disableSSLVerification() {
        session = InsecureConnection.session()
    }
    #endif

    func setClientCredentials(clientID: String, clientSecret: String) {
        self.clientAuthenticator = BasicAuthenticator(username: clientID, password: clientSecret)
    }

    func getToken(completionHandler: @escaping (String?, RestError?) -> Void) {
        // request a new access token if the current token is expired
        guard let refreshDate = refreshDate, refreshDate.timeIntervalSinceNow > 0 else {
            requestToken {
                token, error in

                guard let token = token, error == nil else {
                    completionHandler(nil, error)
                    return
                }
                self.token = token.accessToken
                // Compute refreshDate for token
                let expirationDate = Date(timeIntervalSince1970: Double(token.expiration))
                // We want a little buffer to make sure we refresh proactively
                let buffer = expirationDate.timeIntervalSinceNow * -0.2
                self.refreshDate = expirationDate.addingTimeInterval(buffer)
                completionHandler(self.token, nil)
            }
            return
        }

        // use the existing, valid access token
        completionHandler(self.token, nil)
    }

    internal func errorResponseDecoder(data: Data, response: HTTPURLResponse) -> RestError {
        var errorMessage: String?
        var metadata = [String: Any]()

        do {
            let json = try JSON.decoder.decode([String: JSON].self, from: data)
            metadata["response"] = json
            if case let .some(.string(message)) = json["errorMessage"] {
                errorMessage = message
            } else {
                errorMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
            }
        } catch {
            metadata["response"] = data
            errorMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
        }

        return RestError.http(statusCode: response.statusCode, message: errorMessage, metadata: metadata)
    }

    private func requestToken(completionHandler: @escaping (IAMToken?, RestError?) -> Void) {
        var headerParameters = ["Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json"]
        if let headers = headers {
            headerParameters.merge(headers) { (old, _) in old }
        }
        let form = ["grant_type=urn:ibm:params:oauth:grant-type:apikey", "apikey=\(apiKey)", "response_type=cloud_iam"]
        let request = RestRequest(
            session: session,
            authenticator: clientAuthenticator,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: url,
            headerParameters: headerParameters,
            messageBody: form.joined(separator: "&").data(using: .utf8)
        )
        request.responseObject { (response: RestResponse<IAMToken>?, error) in
            guard let token = response?.result, error == nil else {
                completionHandler(nil, error)
                return
            }
            completionHandler(token, nil)
        }
    }
}

/** An IAM token. */
internal struct IAMToken: Decodable {

    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let expiration: Int

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case expiration = "expiration"
    }
}
