//
//  GoogleLoginManager.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 22/10/2020.
//

import Foundation
import AWSCognitoIdentityProvider
import AppAuth
import SwiftyJSON
import KeychainAccess

public typealias AuthCompletion = (Error?) -> Void

public enum AppAuthError: Error {
    case generic
    case invalidState
}

public class AppAuthLoginManager {
    public static let shared = AppAuthLoginManager()
    
    private var keychain: Keychain
    private var keychainKey = "com.st.clab.STAssetTraking.authKey" /** Is it ok ? */
    // AppAuth
    private var authState: OIDAuthState?
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private var completion: AuthCompletion?
    public var isAuthenticated: Bool { return authState?.isAuthorized ?? false}
    public var dshProvider: LoginProvider = .assetTracking

    public init() {
        self.keychain = Keychain(service: "com.st")
        self.keychain = keychain.accessibility(.afterFirstUnlock)
        self.loadState()
    }
}

extension AppAuthLoginManager: LoginManager {
    public var provider: LoginProvider {
        get {
            return dshProvider
        }
        set {
            dshProvider = newValue
        }
    }
    
    public func authenticate(from controller: UIViewController, completion: @escaping AuthCompletion) {
        self.completion = completion
        
        /*if self.authState != nil {
            refreshAccessToken { error in completion(error) }
            return
        }*/
        
        if(dshProvider==LoginProvider.predictiveMaintenance){
            keychainKey = "com.st.clab.STPredictiveMaintenance.authKey"
            Environment.current = Environment.predmntprod
        }
        
        guard let redirect = URL(string: Environment.current.oauth.redirectUrl) else { return NSLog("Error creating URL") }
        
        let configuration = OIDServiceConfiguration(authorizationEndpoint: URL(string: Environment.current.oauth.authorizationUrl)!,
                                                    tokenEndpoint: URL(string: Environment.current.oauth.tokenUrl)!)
        
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: Environment.current.clientId,
                                              clientSecret: nil,
                                              scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail, "aws.cognito.signin.user.admin"],
                                              redirectURL: redirect,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["identity_provider": Environment.current.identityProvider])
        
        self.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: controller) { [weak self] authState, error in
            guard let self = self, let completion = self.completion else { return }
            
            guard let authState = authState else {
                NSLog("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.authState = nil
                return completion(AppAuthError.invalidState)
            }
            
            self.authState = authState
            
            let idTokenN = authState.lastTokenResponse?.idToken
            let accessTokenN = authState.lastTokenResponse?.accessToken
            
            UserDefaults.standard.set(idTokenN, forKey: "idTokenN")
            UserDefaults.standard.set(accessTokenN, forKey: "accessTokenN")
            
            self.checkLA(idTokenN: idTokenN!, accessTokenN: accessTokenN!) /** To check LA */
            
            print("Got authorization tokens. Access token: " +
                  "\(authState.lastTokenResponse?.accessToken ?? "nil")")
            
            self.saveState()
            completion(error)
        }
    }
    
    public func resumeExternalUserAgentFlow(with url: URL) -> Bool {
        if let authorizationFlow = self.currentAuthorizationFlow,
           authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
            return true
        }
        
        return false
    }
    
    public func buildDeviceManager(completion: @escaping (Result<DeviceManager, DeviceOperationError>) -> Void) {
        
        let dateRefreshToken = UserDefaults.standard.object(forKey: "DateRefreshToken")
        
        if self.authState != nil {
            if(dateRefreshToken == nil){
                self.authState = nil
            }else{
                let dateCreationRefreshToken = Date(timeIntervalSince1970: dateRefreshToken as! TimeInterval)
                var dateComponent = DateComponents()
                dateComponent.day = 25
                let expiringRefreshToken = Calendar.current.date(byAdding: dateComponent, to: dateCreationRefreshToken)
                
                if(Date(timeIntervalSince1970: (Date().timeIntervalSince1970)) >= expiringRefreshToken!){
                    self.authState = nil
                }
            }
        }
        
        guard let idToken = authState?.lastTokenResponse?.idToken else { return completion(.failure(.missingToken)) }
        
        let api = RestAPI()
        
        api.get(path: RestAPI.Paths.authZ, headers: ["Authorization": "Bearer \(idToken)"]) { result in
            switch result {
            case .success(let response):
                guard let data = response.data,
                      let json = try? JSON(data: data),
                      let secretKey = json["Credentials"]["SecretKey"].string,
                      let accessKeyId = json["Credentials"]["AccessKeyId"].string,
                      let sessionTokenId = json["Credentials"]["SessionToken"].string else { return completion(.failure(.missingToken)) }
                let credential = AuthzCredential(accessKeyId: accessKeyId, secretKey: secretKey, sessionToken: sessionTokenId)
                print(credential)
                completion(.success(AwsDeviceManager(credential: credential)))
            case .failure:
                completion(.failure(.missingToken))
            }
        }
    }
    
    public func refreshAccessToken(with completion: @escaping AuthCompletion) {
        guard let authState = self.authState else {
            completion(AppAuthError.invalidState)
            return
        }
        
        authState.performAction { [weak self] _, _, error in
            
            guard let self = self else { return }
            
            if error == nil {
                try? self.saveState()
            }
            
            completion(error)
        }
    }
    
    public func checkLA(idTokenN: String, accessTokenN: String){
        if(provider == LoginProvider.assetTracking){
            let payload = decode(jwtToken: idTokenN)

            let showLA = payload["custom:license_agreement"] != nil

            if(showLA){
                UserDefaults.standard.set(false, forKey: "showLA")
            }else{
                UserDefaults.standard.set(true, forKey: "showLA")
            }
        }else if(provider == LoginProvider.predictiveMaintenance){
            let showLAPM = idTokenN.contains("zoneinfo:1")

            if(showLAPM){
                UserDefaults.standard.set(false, forKey: "showLAPredictive")
            }else{
                UserDefaults.standard.set(true, forKey: "showLAPredictive")
            }
        }
        
    }
    
    public func decode(jwtToken jwt: String) -> [String: Any] {
      let segments = jwt.components(separatedBy: ".")
      return decodeJWTPart(segments[1]) ?? [:]
    }

    public func base64UrlDecode(_ value: String) -> Data? {
      var base64 = value
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

      let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
      let requiredLength = 4 * ceil(length / 4.0)
      let paddingLength = requiredLength - length
      if paddingLength > 0 {
        let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
        base64 = base64 + padding
      }
      return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    public func decodeJWTPart(_ value: String) -> [String: Any]? {
      guard let bodyData = base64UrlDecode(value),
        let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
          return nil
      }
      return payload
    }
    
}

private extension AppAuthLoginManager {
    func saveState() {
        guard let authState = authState else { return }
        
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "DateRefreshToken")
        
        let authStateArchive = CodableWrapper(value: authState)
        do {
            let data = try JSONEncoder().encode(authStateArchive)
            try keychain.set(data, key: keychainKey)
        } catch {
            NSLog("Keychain: saving error", error.localizedDescription)
        }
    }
    
    func loadState() {
        do {
            guard let data = try keychain.getData(keychainKey) else { return NSLog("Keychain: no state to restore.") }
            let wrapper = try JSONDecoder().decode(CodableWrapper<OIDAuthState>.self, from: data)
            authState = wrapper.value
        } catch {
            NSLog("Keychain: loading error", error.localizedDescription)
        }
    }
}
