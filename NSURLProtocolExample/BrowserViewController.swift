//
//  BrowserViewController.swift
//  NSURLProtocolExample
//
//  Created by Zouhair Mahieddine on 7/10/14.
//  Copyright (c) 2014 Zedenem. All rights reserved.
//

import UIKit

class BrowserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var webView: UIWebView!
    
    //MARK: IBAction
    
    @IBAction func buttonGoClicked(_ sender: Any) {
        if self.textField.isFirstResponder {
            self.textField.resignFirstResponder()
        }
        
        self.sendRequest()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.sendRequest()
        
        return true
    }
    
    //MARK: Private
    
    func sendRequest() {
        if let text = self.textField.text {
            let url = NSURL(string:text)!
            let request = NSURLRequest(url: url as URL)
            self.webView.loadRequest(request as URLRequest)
        }
    }
}

