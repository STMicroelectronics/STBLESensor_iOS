//
//  NetworkService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import Combine

public typealias HTTPCode = Int
public typealias HTTPCodes = Range<HTTPCode>

public extension HTTPCodes {
    static let success = 200 ..< 300
}

public struct Response<T> {
    public let value: T?

    public init(value: T?) {
        self.value = value
    }
}

public struct EmptyObject: Codable {
    var message: String?

    public init() {

    }

    enum CodingKeys: String, CodingKey {
        case message
    }
}

public protocol Endpoint {
    var path: String { get }
    var url: URL { get }
    var queryItems: [URLQueryItem] { get }
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum Authentication {
    case none
    case bearer
    case basic
}

// swiftlint:disable line_length

public protocol Network {

    var timeout: TimeInterval { get set }

    var pinnedCertificates: [SecCertificate] { get }

    func request<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                      method: HttpMethod,
                                                      body: Input?,
                                                      headers: [String: String],
                                                      params: [String: String],
                                                      rootKey: String?,
                                                      authentication: Authentication,
                                                      dateEncodingFormatter: DateFormatter,
                                                      dateDecodingFormatter: DateFormatter) -> AnyPublisher<Response<Output>, STError>

    func request<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                      method: HttpMethod,
                                                      body: Input?,
                                                      headers: [String: String],
                                                      params: [String: String],
                                                      rootKey: String?,
                                                      authentication: Authentication,
                                                      dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
                                                      dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> AnyPublisher<Response<Output>, STError>

    func multiPartRequest<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                               body: Input?,
                                                               headers: [String: String],
                                                               params: [String: String],
                                                               data: Data,
                                                               rootKey: String?,
                                                               authentication: Authentication,
                                                               dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
                                                               dateDecodingStrategy: JSONDecoder.DateDecodingStrategy,
                                                               progressCallback: ProgressCallbak?) -> AnyPublisher<Response<Output>, STError>

    func downloadRequest(_ endpoint: Endpoint, authentication: Authentication) -> DownloadTaskPublisher

    func uploadRequest<T: Decodable>(_ endpoint: Endpoint, fileUrl: URL, authentication: Authentication) -> UploadTaskPublisher<T>
}

public class NetworkService: NSObject, Network {
    public var timeout: TimeInterval = 5.0
    public var pinnedCertificates: [SecCertificate] = []

    static let defaultHeaders = [
        "Content-Type": "application/json",
        "cache-control": "no-cache"
    ]

    public convenience init(timeout: TimeInterval, pinnedCertificates: [SecCertificate]) {
        self.init()
        self.timeout = timeout
        self.pinnedCertificates = pinnedCertificates
    }

    internal func buildHeaders(authentication: Authentication,
                               headers: [String: String]) -> [String: String]? {

        var defaultHeaders = NetworkService.defaultHeaders

        defaultHeaders = defaultHeaders.merging(headers) { (_, newValue) in newValue }

        guard let session: NetworkSession = Resolver.shared.resolve() else { return nil }

        if authentication == .bearer {
            let header = "Bearer \(session.accessToken ?? "no_valid_token_found")"
            defaultHeaders["Authorization"] = header
        } else if let username = session.username,
                  let password = session.password,
                  authentication == .basic {
            defaultHeaders["Authorization"] = NetworkService.basicAuthenticationHeader(username: username,
                                                                                       password: password)
        }

        return defaultHeaders
    }

    func run<Output>(_ request: URLRequest,
                     dateDecodingStrategy: JSONDecoder.DateDecodingStrategy,
                     rootKey: String?, delegate: SessionDelegate? = nil) throws -> AnyPublisher<Response<Output>, STError> where Output: Decodable {

        let session = URLSession(configuration: .ephemeral,
                                 delegate: delegate ?? SessionDelegate(pinnedCertificates: self.pinnedCertificates),
                                 delegateQueue: nil)

//        session.uploadTask(with: <#T##URLRequest#>, from: <#T##Data#>)
        return session
            .dataTaskPublisher(for: request)
            .jsonResponse(httpCodes: HTTPCodes.success, dateDecodingStrategy: dateDecodingStrategy, rootKey: rootKey)
            .receive(on: DispatchQueue.main)
            .mapCustomError()
            .eraseToAnyPublisher()
    }

    public func downloadRequest(_ endpoint: Endpoint, authentication: Authentication) -> DownloadTaskPublisher {
        var components = URLComponents(url: endpoint.url,
                                       resolvingAgainstBaseURL: true)

        if endpoint.queryItems.count != 0 {
            components?.queryItems = endpoint.queryItems
        }

        var request = URLRequest(url: endpoint.url)
        request.allHTTPHeaderFields = buildHeaders(authentication: authentication, headers: [:])
        request.timeoutInterval = timeout

        let session = URLSession(configuration: .ephemeral,
                                 delegate: SessionDelegate(pinnedCertificates: self.pinnedCertificates),
                                 delegateQueue: nil)

        return DownloadTaskPublisher(session: session, request: request)
    }

    public func uploadRequest<T: Decodable>(_ endpoint: Endpoint, fileUrl: URL, authentication: Authentication) -> UploadTaskPublisher<T> {
        var components = URLComponents(url: endpoint.url,
                                       resolvingAgainstBaseURL: true)

        if endpoint.queryItems.count != 0 {
            components?.queryItems = endpoint.queryItems
        }

        var urlComps = URLComponents(string: endpoint.url.absoluteString)!
        urlComps.queryItems = endpoint.queryItems
        let result = urlComps.url!

        var request = URLRequest(url: result)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = buildHeaders(authentication: authentication, 
                                                   headers: ["Content-Type":"application/octet-stream"])
        request.timeoutInterval = timeout

        let session = URLSession(configuration: .ephemeral,
                                 delegate: SessionDelegate(pinnedCertificates: self.pinnedCertificates),
                                 delegateQueue: nil)

        return UploadTaskPublisher(session: session, request: request, fileUrl: fileUrl)
    }

    public func multiPartRequest<Input, Output>(_ endpoint: Endpoint,
                                                body: Input?,
                                                headers: [String : String],
                                                params: [String : String],
                                                data: Data,
                                                rootKey: String?,
                                                authentication: Authentication,
                                                dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
                                                dateDecodingStrategy: JSONDecoder.DateDecodingStrategy,
                                                progressCallback: ProgressCallbak?) -> AnyPublisher<Response<Output>, STError> where Input : Encodable, Output : Decodable {
        do {
            var components = URLComponents(url: endpoint.url,
                                           resolvingAgainstBaseURL: true)

            if endpoint.queryItems.count != 0 {
                components?.queryItems = endpoint.queryItems
            }

            guard let url = components?.url else {
                return Fail<Response<Output>, STError>(error: STError.urlNotValid)
                    .eraseToAnyPublisher()
            }

            var multipartRequest = MultipartRequest(url: url)

            multipartRequest.add(
                key: "file",
                fileName: "file.zip",
                fileMimeType: "application/octet-stream",
                fileData: data
            )

            var request = multipartRequest.asURLRequest()
            request.allHTTPHeaderFields = buildHeaders(authentication: authentication, headers: headers)
            request.timeoutInterval = timeout

            if type(of: body) != EmptyObject?.self {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = dateEncodingStrategy
                let bodyData = try? encoder.encode(body)
                request.httpBody = bodyData
            } else if params.keys.count > 0 {
                request.httpBody = encodeParameters(parameters: params)
            }

            return try run(request,
                           dateDecodingStrategy: dateDecodingStrategy,
                           rootKey: rootKey,
                           delegate: SessionDelegate(progressCallback: { progress in

            },
                                                     pinnedCertificates: self.pinnedCertificates))
            .eraseToAnyPublisher()
        } catch let error {
            return Fail<Response<Output>, STError>(error: STError.server(error: error))
                .eraseToAnyPublisher()
        }
    }

    public func request<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                      method: HttpMethod,
                                                      body: Input?,
                                                      headers: [String: String],
                                                      params: [String: String],
                                                      rootKey: String?,
                                                      authentication: Authentication,
                                                      dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
                                                      dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) -> AnyPublisher<Response<Output>, STError> {
        do {
            var components = URLComponents(url: endpoint.url,
                                           resolvingAgainstBaseURL: true)

            if endpoint.queryItems.count != 0 {
                components?.queryItems = endpoint.queryItems
            }

            guard let url = components?.url else {
                return Fail<Response<Output>, STError>(error: STError.urlNotValid)
                    .eraseToAnyPublisher()
            }

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.allHTTPHeaderFields = buildHeaders(authentication: authentication, headers: headers)
            request.timeoutInterval = timeout

            if type(of: body) != EmptyObject?.self {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = dateEncodingStrategy
                let bodyData = try? encoder.encode(body)
                request.httpBody = bodyData
            } else if params.keys.count > 0 {
                request.httpBody = encodeParameters(parameters: params)
            }

            return try run(request, dateDecodingStrategy: dateDecodingStrategy, rootKey: rootKey)
                .eraseToAnyPublisher()
        } catch let error {
            return Fail<Response<Output>, STError>(error: STError.server(error: error))
                .eraseToAnyPublisher()
        }
    }

    public func request<Input: Encodable, Output: Decodable>(_ endpoint: Endpoint,
                                                      method: HttpMethod,
                                                      body: Input?,
                                                      headers: [String: String],
                                                      params: [String: String],
                                                      rootKey: String?,
                                                      authentication: Authentication = .none,
                                                      dateEncodingFormatter: DateFormatter = DateFormatter.iso8601Full,
                                                      dateDecodingFormatter: DateFormatter = DateFormatter.iso8601Full) -> AnyPublisher<Response<Output>, STError> {
        Logger.debug(text: "/// API /// - \(endpoint)")
        return request(endpoint,
                       method: method,
                       body: body,
                       headers: headers,
                       params: params,
                       rootKey: rootKey,
                       authentication: authentication,
                       dateEncodingStrategy: .formatted(dateEncodingFormatter),
                       dateDecodingStrategy: .formatted(dateDecodingFormatter))
    }
}

public extension NetworkService {
    static func basicAuthenticationHeader(username: String, password: String) -> String {
        let userPasswordString = "\(username):\(password)"
        let userPasswordData = userPasswordString.data(using: .utf8)

        guard let base64EncodedCredential = userPasswordData?.base64EncodedString() else { return "" }

        return "Basic \(base64EncodedCredential)"
    }

    func encodeParameters(parameters: [String : String]) -> Data? {
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")"
        }

        return parameterArray.joined(separator: "&").data(using: .utf8)
    }
}

private extension Publisher where Output == URLSession.DataTaskPublisher.Output {

    func jsonResponse<Output>(httpCodes: HTTPCodes,
                              dateDecodingStrategy: JSONDecoder.DateDecodingStrategy,
                              rootKey: String?) -> AnyPublisher<Response<Output>, Error> where Output: Decodable {
        return tryMap { result in
            guard let code = (result.response as? HTTPURLResponse)?.statusCode else {
                throw STError.unknown
            }
            guard httpCodes.contains(code) else {

                if code == 401 {
                    throw STError.notAuthorized
                }

                throw STError.raw(data: result.data)
            }

            if code == 204 {
                return Response<Output>(value: nil)
            }

            if result.data.count == 0 {
                return Response<Output>(value: nil)
            } else if Output.self == Data.self {
                return Response<Output>(value: result.data as? Output)
            } else {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = dateDecodingStrategy
                do {
                    let text = String(data: result.data, encoding: .utf8) ?? ""
                    DispatchQueue.main.async {
                        Logger.debug(mode: .full,
                                     category: "codable",
                                     text: text,
                                     params: [:])
                    }

                    guard let rootKey = rootKey else {
                        let object = try decoder.decode(Output.self, from: result.data)
                        return Response<Output>(value: object)
                    }

                    let object = try decoder.decode(Output.self, from: result.data, keyedBy: rootKey)
                    return Response<Output>(value: object)

                } catch let error {
                    DispatchQueue.main.async {
                        Logger.debug(mode: .full,
                                     category: "codable",
                                     text: error.localizedDescription,
                                     params: [:])
                    }
                }
                return Response<Output>(value: nil)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func mapCustomError() -> AnyPublisher<Self.Output, STError> {
        return self.mapError { error in
            guard let unwrappedError = error as? STError else {
                return STError.server(error: error)
            }

            return unwrappedError

        }
        .eraseToAnyPublisher()
    }
}

extension Array where Element: SecCertificate {
    /// All `Data` values for the contained `SecCertificate`s.
    public var data: [Data] {
        map { SecCertificateCopyData($0) as Data }
    }

}

extension SecTrust {
    public var certificates: [SecCertificate] {
        (0..<SecTrustGetCertificateCount(self)).compactMap { index in
            SecTrustGetCertificateAtIndex(self, index)
        }
    }
}

public struct MultipartRequest {

    public let boundary: String

    private let separator: String = "\r\n"
    private var data: Data

    let url: URL

    public init(url: URL, boundary: String = UUID().uuidString) {
        self.url = url
        self.boundary = boundary
        self.data = .init()
    }

    private mutating func appendBoundarySeparator() {
        data.append("--\(boundary)\(separator)")
    }

    private mutating func appendSeparator() {
        data.append(separator)
    }

    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }

    public mutating func add(key: String, value: String) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }

    public mutating func add(key: String, fileName: String, fileMimeType: String, fileData: Data) {
        appendBoundarySeparator()
        data.append(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.append("Content-Type: \(fileMimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }

    public var httpContentTypeHeadeValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public var httpBody: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }

    public func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        return request
    }
}

public extension Data {

    mutating func append(_ string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}

public typealias ProgressCallbak = (Float) -> ()

public class SessionDelegate: NSObject, URLSessionTaskDelegate {

    private var progressCallback: ProgressCallbak?
    private var pinnedCertificates: [SecCertificate] = []

    init(progressCallback: ProgressCallbak? = nil, pinnedCertificates: [SecCertificate]) {
        self.progressCallback = progressCallback
        self.pinnedCertificates = pinnedCertificates
    }

    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64) {
        guard let progressCallback = progressCallback else { return }

        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        progressCallback(progress);
    }

    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if let trust = challenge.protectionSpace.serverTrust,
           pinnedCertificates.count > 0 {

            SecTrustSetAnchorCertificates(trust, pinnedCertificates as CFArray)
            SecTrustSetAnchorCertificatesOnly(trust, true)

            let serverCertificatesData = Set(trust.certificates.data)
            let pinnedCertificatesData = Set(pinnedCertificates.data)

            if !serverCertificatesData.isDisjoint(with: pinnedCertificatesData) {
                let credential:URLCredential =  URLCredential(trust:trust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.performDefaultHandling, nil)
            }

        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

public struct DownloadTaskPublisher {
    fileprivate let session: URLSession
    fileprivate let request: URLRequest
}

extension DownloadTaskPublisher: Publisher {

    public typealias Output = (URL, URLResponse)
    public typealias Failure = STError

    public func receive<Subscriber>(subscriber: Subscriber)
        where
        Subscriber: Combine.Subscriber,
        Subscriber.Failure == Failure,
        Subscriber.Input == Output
    {
        let subscription = Subscription(subscriber: subscriber, session: session, request: request)
        subscriber.receive(subscription: subscription)
    }
}

extension DownloadTaskPublisher {

    fileprivate final class Subscription {
        private let downloadTask: URLSessionDownloadTask
        init<Subscriber>(subscriber: Subscriber, session: URLSession, request: URLRequest)
            where
            Subscriber: Combine.Subscriber,
            Subscriber.Input == Output,
            Subscriber.Failure == Failure
        {
            downloadTask = session.downloadTask(with: request, completionHandler: { (url, response, error) in

                guard let url = url, let response = response else {
                    subscriber.receive(completion: .failure(STError.server(error: error!)))
                    return
                }

                _ = subscriber.receive((url, response))
                subscriber.receive(completion: .finished)
            })
        }
    }
}

extension DownloadTaskPublisher.Subscription: Subscription {

    fileprivate func request(_ demand: Subscribers.Demand) {
        downloadTask.resume()
    }

    fileprivate func cancel() {
        downloadTask.cancel()
    }
}


public struct UploadTaskPublisher<T: Decodable> {
    fileprivate let session: URLSession
    fileprivate let request: URLRequest
    fileprivate let fileUrl: URL
}

extension UploadTaskPublisher: Publisher {

    public typealias Output = T
    public typealias Failure = STError

    public func receive<Subscriber>(subscriber: Subscriber)
        where
        Subscriber: Combine.Subscriber,
        Subscriber.Failure == Failure,
        Subscriber.Input == Output
    {
        let subscription = Subscription(subscriber: subscriber, session: session, request: request, url: fileUrl)
        subscriber.receive(subscription: subscription)
    }
}

extension UploadTaskPublisher {

    fileprivate final class Subscription {
        private let uploadTask: URLSessionUploadTask
        init<Subscriber>(subscriber: Subscriber, session: URLSession, request: URLRequest, url: URL)
            where
            Subscriber: Combine.Subscriber,
            Subscriber.Input == Output,
            Subscriber.Failure == Failure
        {
            uploadTask = session.uploadTask(with: request,
                                              fromFile: url,
                                              completionHandler: { data, response, error in
                guard let response = response,
                let data = data else {
                    subscriber.receive(completion: .failure(STError.server(error: error!)))
                    return
                }

                var responseObject: Output?

                let decoder = JSONDecoder()
                do {
                    let text = String(data: data, encoding: .utf8) ?? ""
                    DispatchQueue.main.async {
                        Logger.debug(mode: .full,
                                     category: "codable",
                                     text: text,
                                     params: [:])
                    }

                    let object = try decoder.decode(Output.self, from: data, keyedBy: nil)
                    responseObject = object

                } catch let error {
                    DispatchQueue.main.async {
                        Logger.debug(mode: .full,
                                     category: "codable",
                                     text: error.localizedDescription,
                                     params: [:])
                    }
                }

                if responseObject != nil {
                    _ = subscriber.receive(responseObject as! T)
                    subscriber.receive(completion: .finished)
                } else {
                    subscriber.receive(completion: .failure(STError.dataNotValid))
                }
            })
        }
    }
}

extension UploadTaskPublisher.Subscription: Subscription {

    fileprivate func request(_ demand: Subscribers.Demand) {
        uploadTask.resume()
    }

    fileprivate func cancel() {
        uploadTask.cancel()
    }
}
