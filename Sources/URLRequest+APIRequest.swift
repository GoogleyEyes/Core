//
//  URLRequest+APIRequest.swift
//  GoogleyEyesCore
//
//  Created by Matthew Wyskiel on 4/21/17.
//
//

import Foundation

extension URLRequest {
    init(_ apiRequest: APIRequest) {
        let urlString = apiRequest.baseURL + "/\(apiRequest.serviceName)/\(apiRequest.apiVersion)/\(apiRequest.endpoint)"
        let url = URL(string: urlString)!
        self.init(url: url)
        
        var headers: [String: String] = [:]
        if let accessToken = apiRequest.accessToken {
            headers["Authorization"] = "Bearer \(accessToken)"
        } else if let apiKey = apiRequest.apiKey {
            apiRequest.queryParams["key"] = apiKey
        }
        
        if let uploadParameters = apiRequest.uploadParameters {
            headers["Content-Type"] = uploadParameters.mimeType
        }
        
        encodeURLParameters(apiRequest.queryParams)
        encodeJSONParameters(apiRequest.postBody)
        
    }
    
    mutating func encodeURLParameters(_ parameters: [String: Any]?) {
        guard let parameters = parameters else { return }
        
        if let method = HTTPMethod(rawValue: httpMethod ?? "GET"), encodesParametersInURL(with: method) {
            guard let url = url else {
                return
            }
            
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                self.url = urlComponents.url
            }
        } else {
            if value(forHTTPHeaderField: "Content-Type") == nil {
                setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            
            httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
        }
    }
    
    mutating func encodeJSONParameters(_ parameters: [String: Any]?, options: JSONSerialization.WritingOptions = []) {
        guard let parameters = parameters else { return }
        
        guard let data = try? JSONSerialization.data(withJSONObject: parameters, options: options) else { return } // TODO: maybe throw an error?
        
        if value(forHTTPHeaderField: "Content-Type") == nil {
            setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        httpBody = data
    }
}
