//
//  ApiClient.swift
//  Reactive Playground
//
//  Created by Michael Kao on 19/11/15.
//  Copyright © 2015 Michael Kao. All rights reserved.
//

import Foundation
import RxSwift

class ApiClient {
    let session =  NSURLSession.sharedSession()
    
    func loginObservable(email: String, password: String) -> Observable<Bool> {
        let URL = NSURL(string: "http://localhost:3000/?username=\(email)&password=\(password)")!        // much wow, much save
        let request = NSURLRequest(URL: URL)
        
        return self.session.rx_response(request)
            .map({ (data, response) -> Bool in
                return response.statusCode == 200
            })
    }
    
    func searchObservable(query: String) -> Observable<Array<String>> {
        let URL = NSURL(string: "http://localhost:3000/words/?q=\(query)&max=20")!
        let request = NSURLRequest(URL: URL)
        
        return self.session.rx_JSON(request)
            .map({ result -> [String] in
                return result as! Array<String>
            })
    }
}