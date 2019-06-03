//
//  MyURLProtocol.swift
//  NSURLProtocolExample
//
//  Created by kidnapper on 2019/6/3.
//  Copyright © 2019 Zedenem. All rights reserved.
//

import UIKit

var requestCount: Int = 0

class MyURLProtocol: URLProtocol, URLSessionDataDelegate {
    
    static let myURLProtocolHandledKey: String = "MyURLProtocolHandledKey"
    
    private lazy var session: URLSession? = URLSession(configuration: .default, delegate: self, delegateQueue: URLSession.shared.delegateQueue)
    private var sessionTask: URLSessionTask?
    
    override class func canInit(with request: URLRequest) -> Bool {
        if URLProtocol.property(forKey: myURLProtocolHandledKey, in: request) != nil {
            return false
        }
        print("Request #\(requestCount): URL = \(String(describing: request.url?.absoluteString))")
        requestCount += 1
        
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    override func startLoading() {
        guard let newRequest: NSMutableURLRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else { return }
        URLProtocol.setProperty(true, forKey: MyURLProtocol.myURLProtocolHandledKey, in: newRequest)
        
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        
        sessionTask?.resume()
        session?.finishTasksAndInvalidate()
    }
    
    override func stopLoading() {
        self.sessionTask?.cancel()
        self.sessionTask = nil
    }
    
    // MARK: URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
}
