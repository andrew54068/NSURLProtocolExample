//
//  MyURLProtocol.swift
//  NSURLProtocolExample
//
//  Created by kidnapper on 2019/6/3.
//  Copyright © 2019 Zedenem. All rights reserved.
//

import UIKit
import CoreData

var requestCount: Int = 0

class MyURLProtocol: URLProtocol, URLSessionDataDelegate {
    
    private let cachedURLResponse: String = "CachedURLResponse"
    
    static let myURLProtocolHandledKey: String = "MyURLProtocolHandledKey"
    
    private lazy var session: URLSession? = URLSession(configuration: .default, delegate: self, delegateQueue: URLSession.shared.delegateQueue)
    private var sessionTask: URLSessionTask?
    
    var mutableData: Data?
    var response: URLResponse!
    
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
        DispatchQueue.main.async {
            if let possibleCachedResponse = self.cachedResponseForCurrentRequest() {
                print("Serving response from cache")
                let mimeType = possibleCachedResponse.value(forKey: "mimeType") as? String
                let data: Data = possibleCachedResponse.value(forKey: "data") as? Data ?? Data()
                let encoding = possibleCachedResponse.value(forKey: "encoding") as? String
                let response = URLResponse(url: self.request.url!, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: encoding)
                
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: data)
                self.client?.urlProtocolDidFinishLoading(self)
            } else {
                guard let newRequest: NSMutableURLRequest = (self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else { return }
                URLProtocol.setProperty(true, forKey: MyURLProtocol.myURLProtocolHandledKey, in: newRequest)
                
                self.sessionTask = self.session?.dataTask(with: newRequest as URLRequest)
                
                self.sessionTask?.resume()
                self.session?.finishTasksAndInvalidate()
            }
        }
    }
    
    override func stopLoading() {
        self.sessionTask?.cancel()
        self.sessionTask = nil
    }
    
    private func saveCachedResponse() {
        print("Saving cached response")
        
        DispatchQueue.main.async {
            guard let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext else { return }
            
            let cachedResponse = NSEntityDescription.insertNewObject(forEntityName: self.cachedURLResponse, into: context)
            cachedResponse.setValue(self.mutableData, forKey: "data")
            cachedResponse.setValue(self.request.url?.absoluteString, forKey: "url")
            cachedResponse.setValue(NSDate(), forKey: "timestamp")
            cachedResponse.setValue(self.response.mimeType, forKey: "mimeType")
            cachedResponse.setValue(self.response.textEncodingName, forKey: "encoding")
            
            do {
                try context.save()
                print("Cache the response successfully.")
            } catch {
                print("error: \(error.localizedDescription)")
                print("Could not cache the response")
            }
        }
    }
    
    private func cachedResponseForCurrentRequest() -> NSManagedObject? {
        guard let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext else { return nil }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: cachedURLResponse, in: context)
        fetchRequest.entity = entity
        
        let predicate = NSPredicate(format: "url == %@", self.request.url!.absoluteString)
        fetchRequest.predicate = predicate
        
        do {
            if let possibleResult: [NSManagedObject] = try context.fetch(fetchRequest) as? [NSManagedObject],
                !possibleResult.isEmpty {
                return possibleResult[0]
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        mutableData?.append(data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.response = response
        mutableData = Data()
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        client?.urlProtocolDidFinishLoading(self)
        saveCachedResponse()
    }
    
}
