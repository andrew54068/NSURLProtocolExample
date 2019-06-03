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
    
    override class func canInit(with request: URLRequest) -> Bool {
        print("Request #\(requestCount): URL = \(String(describing: request.url?.absoluteString))")
        requestCount += 1
        return false
    }
    
}
