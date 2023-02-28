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

/**
 An `Authenticator` adds authentication to a `RestRequest`.

 An Authenticator adapts a `RestRequest` by adding authentication credentials to it. Authentication
 is expressed as an adapter because the credentials may be dynamic — they may change over time. For example,
 a `RestRequest` might use one token, fail with an authentication error, then retry using a refreshed token.
 The `RestRequest` does not need to be rebuilt, but should be updated with a new token value.
 */
public protocol Authenticator {

    /**
     Authenticate a `RestRequest`.

     - parameter request: The request that should be authenticated.
     - parameter completionHandler: The completion handler to execute with the authenticated `RestRequest`.
     */
    func authenticate(request: RestRequest, completionHandler: @escaping (RestRequest?, RestError?) -> Void)

    /**
     Authenticate a `URLRequest`.

     - parameter request: The request that should be authenticated.
     - parameter completionHandler: The completion handler to execute with the authenticated `URLRequest`.
     */
    func authenticate(request: URLRequest, completionHandler: @escaping (URLRequest?, RestError?) -> Void)
}

/** No authentication. */
public class NoAuthAuthenticator: Authenticator {

    public init() {}

    public func authenticate(request: RestRequest, completionHandler: @escaping (RestRequest?, RestError?) -> Void) {
        completionHandler(request, nil)
    }

    public func authenticate(request: URLRequest, completionHandler: @escaping (URLRequest?, RestError?) -> Void) {
        completionHandler(request, nil)
    }
}

/** Authenticate with basic authentication. */
public class BasicAuthenticator: Authenticator {

    let encodedCredentials: String

    public init(username: String, password: String) {
        let data = (username + ":" + password).data(using: .utf8)!
        self.encodedCredentials = data.base64EncodedString()
    }

    public func authenticate(request: RestRequest, completionHandler: @escaping (RestRequest?, RestError?) -> Void) {
        var request = request
        request.headerParameters["Authorization"] =  "Basic \(encodedCredentials)"
        completionHandler(request, nil)
    }

    public func authenticate(request: URLRequest, completionHandler: @escaping (URLRequest?, RestError?) -> Void) {
        var request = request
        request.addValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        completionHandler(request, nil)
    }
}

/** Authenticate with a static bearer token. */
public class BearerTokenAuthenticator: Authenticator {

    /**
     The bearer token
     */
    public var bearerToken: String

    public init(bearerToken: String) {
        self.bearerToken = bearerToken
    }

    public static func authenticate(request: RestRequest, bearerToken: String, completionHandler: @escaping (RestRequest?, RestError?) -> Void) {
        var request = request
        request.headerParameters["Authorization"] = "Bearer \(bearerToken)"
        completionHandler(request, nil)
    }

    public static func authenticate(request: URLRequest, bearerToken: String, completionHandler: @escaping (URLRequest?, RestError?) -> Void) {
        var request = request
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        completionHandler(request, nil)
    }

    public func authenticate(request: RestRequest, completionHandler: @escaping (RestRequest?, RestError?) -> Void) {
        BearerTokenAuthenticator.authenticate(request: request, bearerToken: bearerToken, completionHandler: completionHandler)
    }

    public func authenticate(request: URLRequest, completionHandler: @escaping (URLRequest?, RestError?) -> Void) {
        BearerTokenAuthenticator.authenticate(request: request, bearerToken: bearerToken, completionHandler: completionHandler)
    }
}

public protocol TokenSource {
    /**
     Obtain a new authentication token
     */
    func getToken(completionHandler: @escaping (String?, RestError?) -> Void)

    /**
     HTTP request headers to set in all token requests.
     */
    var headers: [String: String]? {get set}

    #if !os(Linux)
    /**
     Allow network requests to a server without verification of the server certificate.
     **IMPORTANT**: This should ONLY be used if truly intended, as it is unsafe otherwise.
     */
    func disableSSLVerification()
    #endif
}

/** Authenticate with a token obtained from a token source. */
public class TokenSourceAuthenticator: Authenticator {

    var tokenSource: TokenSource

    public init(tokenSource: TokenSource) {
        self.tokenSource = tokenSource
    }

    public var headers: [String: String]? {
        get {
            return self.tokenSource.headers
        }
        set(newVal) {
            self.tokenSource.headers = newVal
        }
    }

    #if !os(Linux)
    /**
     Allow network requests to a server without verification of the server certificate.
     **IMPORTANT**: This should ONLY be used if truly intended, as it is unsafe otherwise.
     */
    public func disableSSLVerification() {
        tokenSource.disableSSLVerification()
    }
    #endif

    public func authenticate(request: RestRequest, completionHandler: @escaping (RestRequest?, RestError?) -> Void) {
        tokenSource.getToken { token, error in
            if let token = token {
                BearerTokenAuthenticator.authenticate(request: request, bearerToken: token, completionHandler: completionHandler)
             } else {
                completionHandler(nil, error ?? RestError.http(statusCode: 400, message: "Token Source error", metadata: nil))
            }
        }
    }

    public func authenticate(request: URLRequest, completionHandler: @escaping (URLRequest?, RestError?) -> Void) {
        tokenSource.getToken { token, error in
            if let token = token {
                BearerTokenAuthenticator.authenticate(request: request, bearerToken: token, completionHandler: completionHandler)
            } else {
                completionHandler(nil, error ?? RestError.http(statusCode: 400, message: "Token Source error", metadata: nil))
            }
        }
    }
}
