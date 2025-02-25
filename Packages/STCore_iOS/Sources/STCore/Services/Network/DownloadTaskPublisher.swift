//
//  DownloadTaskPublisher.swift
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

public struct DownloadTaskPublisher {
    private let session: URLSession
    private let request: URLRequest

    public init(session: URLSession, request: URLRequest) {
        self.session = session
        self.request = request
    }
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

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    subscriber.receive(completion: .failure(STError.notAuthorized))
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
