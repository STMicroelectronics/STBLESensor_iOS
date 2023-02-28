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

public class CloudPakForDataAuthenticator: TokenSourceAuthenticator {

    public init(username: String, password: String, url: String) {
        super.init(tokenSource: CloudPakForDataTokenSource(username: username, password: password, url: url))
    }
}

class CloudPakForDataTokenSource: TokenSource {

    let url: String

    var headers: [String: String]?

    var session = URLSession(configuration: URLSessionConfiguration.default)

    private var clientAuthenticator: Authenticator

    private var token: String? = nil {
        didSet {
            if let token = token {
                // ICP tokens are JWTs
                let jwtExpiration = JWT.getTokenExpiration(token: token)
                // We want a little buffer to make sure we refresh proactively
                let buffer = jwtExpiration?.timeIntervalSinceNow ?? 0 * -0.2
                refreshDate = jwtExpiration?.addingTimeInterval(buffer)
            } else {
                refreshDate = nil
            }
        }
    }
    private var refreshDate: Date?

    let urlSuffix = "/v1/preauth/validateAuth"

    init(username: String, password: String, url: String) {
        self.clientAuthenticator = BasicAuthenticator(username: username, password: password)
        if url.hasSuffix(urlSuffix) {
            self.url = url
        } else {
            self.url = url + urlSuffix
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

    func getToken(completionHandler: @escaping (String?, RestError?) -> Void) {
        // request a new access token if the current token is expired
        guard let refreshDate = refreshDate, refreshDate.timeIntervalSinceNow > 0 else {
            requestToken(completionHandler: completionHandler)
            return
        }

        // use the existing, valid access token
        completionHandler(token, nil)
    }

    internal func errorResponseDecoder(data: Data, response: HTTPURLResponse) -> RestError {
        let message = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
        return RestError.http(statusCode: response.statusCode, message: message, metadata: nil)
    }

    private func requestToken(completionHandler: @escaping (String?, RestError?) -> Void) {
        var headerParameters = ["Accept": "application/json"]
        if let headers = headers {
            headerParameters.merge(headers) { (old, _) in old }
        }
        let request = RestRequest(
            session: session,
            authenticator: clientAuthenticator,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: url,
            headerParameters: headerParameters
        )
        request.responseObject { (response: RestResponse<CP4DToken>?, error) in
            guard let result = response?.result, error == nil else {
                completionHandler(nil, error)
                return
            }
            self.token = result.accessToken
            completionHandler(self.token, nil)
        }
    }
}

/** CP4D getToken response. */
internal struct CP4DToken: Decodable {
    let accessToken: String
}
