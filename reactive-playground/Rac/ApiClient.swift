//
//  ApiClient.swift
//  Reactive Playground
//
//  Created by Michael Kao on 19/11/15.
//  Copyright © 2015 Michael Kao. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ApiClient {
    let session =  NSURLSession.sharedSession()
    
    func loginSignal(username: String, password: String) -> SignalProducer<Bool, NSError> {
        let URL = NSURL(string: "http://localhost:3000/?username=\(username)&password=\(password)")!        // much wow, much save
        let request = NSURLRequest(URL: URL)
        
        return self.session.rac_dataWithRequest(request)
            .map({ (data, response) -> Bool in
                if let response = response as? NSHTTPURLResponse {
                    return response.statusCode == 200
                } else {
                    return false
                }
            })
    }
    
    func searchSignal(query: String) -> SignalProducer<Array<String>, NSError> {
        let URL = NSURL(string: "http://localhost:3000/words/?q=\(query)&max=20")!
        let request = NSURLRequest(URL: URL)
        
        return self.session.rac_dataWithRequest(request)
            .map({ (data, response) -> NSArray? in
                
                let anyObj: AnyObject?
                anyObj = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                
                return anyObj as? NSArray
            })
            .map({ words -> [String]? in
                return words as? [String]
            })
            .ignoreNil()
    }
}