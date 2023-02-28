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

public class JWT {
    // Ref: https://tools.ietf.org/html/rfc7519
    static func getTokenExpiration(token: String) -> Date? {
        let parts = token.components(separatedBy: ".")
        if parts.count == 3 {
            let base64Data = base64urlToBase64(base64url: String(parts[1]))
            let jwtPayload = Data(base64Encoded: base64Data)
            if let jwtClaims = try? JSONSerialization.jsonObject(with: jwtPayload!, options: []) as? [String: Any],
                let exp = jwtClaims?["exp"] as? TimeInterval {
                return Date(timeIntervalSince1970: exp)
            }
        }
        return nil
    }

    // Ref: https://brockallen.com/2014/10/17/base64url-encoding/
    static internal func base64urlToBase64(base64url: String) -> String {
        var base64 = base64url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
}
