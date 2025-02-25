//
//  UploadTaskPublisher.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import Combine

public struct UploadTaskPublisher<T: Decodable> {
    private let session: URLSession
    private let request: URLRequest
    private let fileUrl: URL

    public init(session: URLSession, request: URLRequest, fileUrl: URL) {
        self.session = session
        self.request = request
        self.fileUrl = fileUrl
    }
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
                    _ = subscriber.receive(responseObject!)
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
