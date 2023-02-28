 //
 //  RestAPI.swift
 //  SmarTagCloudAssetTracking
 //
 //  Created by Giovanni Visentini on 02/09/2019.
 //  Copyright © 2019 Giovanni Visentini. All rights reserved.
 //

 import Foundation

internal enum RestAPIComunicationError: Error{
  case invalidUrl
  case invalidResponse
  case offline
  case invalidRequest
  case unknown
}
 
 
 internal class RestAPI{

    
     public typealias RestApiResult = Result<(HTTPURLResponse,Data?),RestAPIComunicationError>
     
    private let mBaseUrl:URL
    private let mHeaderValue:[String:String]
     
    init(baseUrl:URL, headerValue:[String:String] = [:]){
         mBaseUrl = baseUrl
         mHeaderValue = headerValue
     }
     
     private func setUpHeader(to request: inout URLRequest){
        for (key,value) in mHeaderValue {
            request.addValue(value, forHTTPHeaderField: key)
        }
     }
     
     private func buildRequestUrl(path:String, urlParam:[String:String])->URL?{
         //var urlComponent = URLComponents(url: mBaseUrl, resolvingAgainstBaseURL: false)
         //TODO: WHY WITH MBASEURL IS NOT WORKING??
         var urlComponent = URLComponents(string: mBaseUrl.description)
         urlComponent?.path = path
         urlComponent?.queryItems = urlParam.toQueryItem
         return urlComponent?.url
     }
     
    func post(path:String, urlParam:[String:String], requestBody:Data?, onComplete:@escaping (RestApiResult)->()){
        guard let finalUrl = buildRequestUrl(path: path, urlParam: urlParam) else{
            onComplete(.failure(.invalidUrl))
            return
        }
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "POST"
        setUpHeader(to: &request)
        request.httpBody = requestBody
         URLSession.shared.dataTask(with: request){ (data, response, error) in
             let result = RestAPI.extractResult(data,response,error)
             onComplete(result)
         }.resume()
     }
     
     private static func extractResult(_ data:Data?,_ response:URLResponse?,_ error:Error?) -> RestApiResult{
         if let err = error{
             return manageError(err)
         }
        guard let httpResponse = response as? HTTPURLResponse else{
            return .failure(.invalidResponse)
        }
        return .success((httpResponse,data))
     }
     
     private static func manageError(_ error:Error) -> RestApiResult{
         switch (error as NSError).code {
         case NSURLErrorNotConnectedToInternet:
             return .failure(.offline)
         default:
             return .failure(.unknown)
         }
     }
     
 }

 fileprivate extension Dictionary where Key == String, Value == String {
     var toQueryItem: [URLQueryItem]{
         return self.map{ key, value in URLQueryItem(name: key, value: value)}
     }
 }
