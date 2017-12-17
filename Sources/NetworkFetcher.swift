//
//  NetworkFetcher.swift
//  GoogleyEyesCore
//
//  Created by Matthew Wyskiel on 4/17/17.
//
//

import Foundation

public class NetworkFetcher {
    var request: APIRequest
    var session: URLSession
    var sessionDelegate: NetworkFetcherSessionDelegate
    
    public init(request: APIRequest) {
        self.request = request
        self.sessionDelegate = NetworkFetcherSessionDelegate(request: request)
        self.session = URLSession(configuration: .default, delegate: self.sessionDelegate, delegateQueue: .main)
    }
    
    func handleResponse(_ tuple: (Data?,URLResponse?,Error?)) -> Result<Data> {
        guard tuple.2 == nil else {
            return .error(tuple.2!) // TODO: make richer?
        }
        guard let data = tuple.0 else {
            return .error(NetworkFetcherError.noData)
        }
        return .success(data)
    }
    
    func handleResponseURL(_ tuple: (URL?,URLResponse?,Error?)) -> Result<URL> {
        guard tuple.2 == nil else {
            return .error(tuple.2!) // TODO: make richer?
        }
        guard let URL = tuple.0 else {
            return .error(NetworkFetcherError.downloadRetrievingError)
        }
        
        return .success(URL)
    }
    
    
    public func execute(completion: @escaping (Result<Data>) -> ()) {
        
        guard !(request.isFileDownload) else {
            completion(.error("wrong function: use executeDownload()"))
            return
        }
        
        if let uploadParameters = request.uploadParameters {
            session.uploadTask(with: URLRequest(request), from: uploadParameters.data) {
                completion(self.handleResponse(($0, $1, $2)))
            }.resume()
        } else {
            session.dataTask(with: URLRequest(request)) {
                completion(self.handleResponse(($0, $1, $2)))
            }.resume()
        }
    }
    
    public func executeDownload(completion: @escaping (Result<URL>) -> ()) {
        guard request.isFileDownload else {
            completion(.error("wrong function: use execute()"))
            return
        }
        session.downloadTask(with: URLRequest(request)) {
            completion(self.handleResponseURL(($0, $1, $2)))
        }.resume()
    }
}

enum NetworkFetcherError: Error {
    case noData
    case downloadRetrievingError
}

extension String: Error { }

class NetworkFetcherSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate, URLSessionStreamDelegate {
    
    var request: APIRequest
    init(request: APIRequest) {
        self.request = request
        super.init()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // bypassed
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        request.downloadProgressHandler?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        request.uploadParameters?.progressHandler?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
    }
    
}
