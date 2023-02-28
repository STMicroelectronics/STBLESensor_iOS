//
//  RestAPI.swift
//  SmarTagCloudAssetTracking
//
//  Created by Giovanni Visentini on 02/09/2019.
//  Copyright © 2019 Giovanni Visentini. All rights reserved.
//

import Foundation

class RestAPI {
    public typealias RestApiResult = Result<RestAPIResponse, ComunicationError>
    public typealias RestApiCompletion = (RestApiResult) -> Void

    enum ComunicationError: Error{
        case invalidUrl
        case invalidResponse
        case offline
        case invalidRequest
        case unknown
    }
        
    private let baseUrl: URL
    
    init(baseUrl: URL = URL(string: Environment.current.baseUrl)!) {
        self.baseUrl = baseUrl
    }
    
    func get(path: String, params: KeyValuePairs<String, String> = [:], headers: [String: String] = [:], credential: AuthzCredential? = nil, onComplete: @escaping RestApiCompletion) {
        guard let url = buildRequestUrl(path: path, params: params) else {
            onComplete(.failure(.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        execute(request: request, headers: headers, credential: credential, completion: onComplete)
    }
    
    func post(path: String, params: KeyValuePairs<String, String> = [:], headers: [String: String] = [:], credential: AuthzCredential? = nil, onComplete: @escaping RestApiCompletion) {
        guard let url = buildRequestUrl(path: path, params: params) else{
            onComplete(.failure(.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        execute(request: request, headers: headers, credential: credential, completion: onComplete)
    }
    
    func post(path: String, data: Data, headers: [String: String] = [:], credential: AuthzCredential? = nil, onComplete: @escaping RestApiCompletion) {
        guard let url = buildRequestUrl(path: path, params: [:]) else {
            onComplete(.failure(.invalidUrl))
            return
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        execute(request: request, headers: headers, credential: credential, completion: onComplete)
    }
    
    func delete(path: String, params: KeyValuePairs<String, String> = [:], headers: [String: String] = [:], credential: AuthzCredential? = nil, onComplete: @escaping RestApiCompletion) {
        guard let url = buildRequestUrl(path: path, params: params) else {
            onComplete(.failure(.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        execute(request: request, headers: headers, credential: credential, completion: onComplete)
    }
}

private extension RestAPI {
    func addHeaders(_ headers: [String: String], to request: inout URLRequest) {
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
    }
    
    func buildRequestUrl(path: String, params: KeyValuePairs<String, String>) -> URL? {
        var urlComponent = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        urlComponent?.path = path
        // AWS v4 cryto signature uses also alphabetically ordererd query params; this keeps things consistent.
        urlComponent?.queryItems = params.sortedQueryItems
        return urlComponent?.url
    }
    
    func execute(request: URLRequest, headers: [String: String], credential: AuthzCredential? = nil, completion: @escaping RestApiCompletion) {
        var updatedRequest = request
        
        addHeaders(headers, to: &updatedRequest)
        
        if let cred = credential,
           let signedRequest = URLRequestSigner().sign(request: updatedRequest, secretSigningKey: cred.secretKey, accessKeyId: cred.accessKeyId, sessionId: cred.sessionToken) {
            updatedRequest = signedRequest
        }
        
        NSLog("🔥 REQUEST -> URL: \(updatedRequest.httpMethod!) \(updatedRequest.url!) \nPARAM: \(URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems)\nBODY: \(updatedRequest.httpBody?.prettyJSONString ?? "𐄂")\nHeaders: \(request.allHTTPHeaderFields)")

        URLSession.shared.dataTask(with: updatedRequest) { (data, response, error) in
            let result = RestAPI.extractResult(data, response, error)
            completion(result)
        }
        .resume()
    }
    
    static func extractResult(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> RestApiResult {
        if let err = error {
            return manageError(err)
        }
        
        if let data = data,
           let httpResponse = response as? HTTPURLResponse {
            NSLog("🔥 RESPONSE -> \(data.prettyJSONString ?? "𐄂")")
            switch(httpResponse.statusCode) {
            case 200...299:
                if let decodedResponse = try? JSONDecoder().decode(RestAPIResponse.self, from: data) {
                    return .success(decodedResponse)
                } else {
                    return .success(RestAPIResponse(statusCode: 200, body: nil, headers: [:], data: data))
                }
            case 400:
                return .failure(.invalidRequest)
            case 500:
                return .failure(.invalidRequest)
            default:
                return .failure(.unknown)
            }
            
        }
        
        return .failure(.unknown)
    }
    
    static func manageError(_ error:Error) -> RestApiResult {
        switch (error as NSError).code {
        case NSURLErrorNotConnectedToInternet:
            return .failure(.offline)
        default:
            return .failure(.unknown)
        }
    }
}

private extension KeyValuePairs where Key == String, Value == String {
    var sortedQueryItems: [URLQueryItem] {
        let array = Array(self)
        return array
            .sorted { $0.key < $1.key }
            .map { .init(name: $0.key, value: $0.value) }
    }
}
