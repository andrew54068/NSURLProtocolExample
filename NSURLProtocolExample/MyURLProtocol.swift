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
    
    private static let myURLProtocolHandledKey: String = "MyURLProtocolHandledKey"
    
    var connection: NSURLConnection!
    
    override class func canInit(with request: URLRequest) -> Bool {
        print("Request #\(requestCount): URL = \(String(describing: request.url?.absoluteString))")
        requestCount += 1
        
        if URLProtocol.property(forKey: myURLProtocolHandledKey, in: request) != nil {
            return false
        }
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
        self.connection = NSURLConnection(request: newRequest as URLRequest, delegate: self)
    }
    
    override func stopLoading() {
        if self.connection != nil {
            self.connection.cancel()
        }
        self.connection = nil
    }
    
}
