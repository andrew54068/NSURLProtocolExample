//
//  MyURLProtocol.swift
//  NSURLProtocolExample
//
//  Created by kidnapper on 2019/6/3.
//  Copyright © 2019 Zedenem. All rights reserved.
//

import UIKit

var requestCount: Int = 0

class MyURLProtocol: URLProtocol {
    
    var connection: NSURLConnection!
    
    override class func canInit(with request: URLRequest) -> Bool {
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
        self.connection = NSURLConnection(request: self.request, delegate: self)
    }
    
    override func stopLoading() {
        if self.connection != nil {
            self.connection.cancel()
        }
        self.connection = nil
    }
    
}
