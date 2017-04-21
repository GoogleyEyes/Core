//
//  APIRequest.swift
//  GoogleyEyesCore
//
//  Created by Matthew Wyskiel on 4/17/17.
//
//

import Foundation

/// HTTP method definitions.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public class UploadParameters {
    public var progressHandler: ((_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> ())? = nil
    public var mimeType: String
    public var data: Data
    
    public init(data: Data, mimeType: String) {
        self.data = data
        self.mimeType = mimeType
    }
}

public class APIRequest {
    public var baseURL = "https://www.googleapis.com"
    public var accessToken: String?
    public var apiKey: String?
    public var method: HTTPMethod
    public var serviceName: String
    public var apiVersion: String
    public var endpoint: String
    public var queryParams: [String: String]
    public var postBody: [String: Any]?
    public var uploadParameters: UploadParameters?
    public var isFileDownload: Bool = false
    public var downloadProgressHandler: ((_ bytesDownloaded: Int64, _ totalBytesDownloaded: Int64, _ totalBytesExpectedToDownload: Int64) -> ())? = nil
    // deal with completion in network fetcher
    
    public init(method: HTTPMethod = .get, serviceName: String, apiVersion: String, endpoint: String, queryParams: [String: String] = [:], postBody: [String: Any]? = nil, uploadParameters: UploadParameters? = nil, accessToken: String? = nil, apiKey: String? = nil) {
        self.method = method
        self.serviceName = serviceName
        self.apiVersion = apiVersion
        self.endpoint = endpoint
        self.queryParams = queryParams
        self.accessToken = accessToken
        self.apiKey = apiKey
        self.postBody = postBody
        self.uploadParameters = uploadParameters
    }
}
