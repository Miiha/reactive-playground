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
    
    func loginSignal(email: String, password: String) -> SignalProducer<Bool, NSError> {
        let URL = NSURL(string: "http://localhost:3000/?username=\(email)&password=\(password)")!        // much wow, much save
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
            .flatMap(.Latest, transform: { (data, response) -> SignalProducer<Array<String>, NSError> in
                return SignalProducer { observer, disposable in
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                        if let words = json as? [String] {
                            observer.sendNext(words)
                            observer.sendCompleted()
                        } else {
                            observer.sendFailed(NSError(domain:"json serialization error", code: 0, userInfo: nil))
                        }
                    } catch let error as NSError {
                        observer.sendFailed(error)
                    }
                }
            })
    }
}