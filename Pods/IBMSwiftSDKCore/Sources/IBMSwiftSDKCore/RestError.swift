/**
 * Copyright IBM Corporation 2016, 2019
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

/// An error from processing a network request or response.
public enum RestError {

    /// No response was received from the server.
    case noResponse

    /// No data was returned from the server.
    case noData

    /// Failed to save the downloaded data.
    /// The specified file may already exist or the disk may be full.
    case saveData

    /// Failed to serialize value(s) to data.
    case serialization(values: String)

    /// Failed to deserialize value(s) to data.
    case deserialization(values: String)

    /// Failed to replace special characters in the
    /// URL path with percent encoded characters.
    case urlEncoding(path: String)

    /// The request failed because the URL was malformed.
    case badURL
    
    /// The service URL was nil
    case noEndpoint
    
    /// The SSL certificate was untrusted
    case sslCertificateUntrusted

    /// Generic HTTP error with a status code and description.
    case http(statusCode: Int?, message: String?, metadata: [String: Any]?)

    /// Error that does not fall under any other `RestError` category
    case other(message: String?, metadata: [String: Any]?)
}

extension RestError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .noResponse:
            return "No response was received from the server"
        case .noData:
            return "No data was returned by the server"
        case .saveData:
            return "Failed to save the downloaded data. The specified file may already exist or the disk may be full."
        case .serialization(let values):
            return "Failed to serialize " + values
        case .deserialization(let values):
            return "Failed to deserialize " + values
        case .urlEncoding(let path):
            return "Failed to add percent encoding to \(path)"
        case .badURL:
            return "Malformed URL"
        case .noEndpoint:
            return "No service URL was provided."
        case .sslCertificateUntrusted:
            #if os(Linux)
            return "The connection failed because the SSL certificate is not valid. Additionally, self-signed certificates are not supported in the Swift SDK on Linux."
            #else
            return "The connection failed because the SSL certificate is not valid. To use a self-signed certificate, call the disableSSLVerification method on your service class."
            #endif
        case .http(_, let message, _):
            return message
        case .other(let message, _):
            return message
        }
    }
}
