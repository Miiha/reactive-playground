//
//  ViewController.swift
//  Reactive Playground
//
//  Created by Michael Kao on 06/11/15.
//  Copyright © 2015 Michael Kao. All rights reserved.
//

import UIKit
import ReactiveCocoa

class LoginViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let apiClient = ApiClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // when email text is changed
        let emailTextSignal = emailField.rac_textSignal().toSignalProducer()
            .flatMapError { error in
                return SignalProducer<AnyObject?, NoError>.empty
            }
            .map({ text -> String in
                return text as! String
            })
        
        // when password text is changed
        let passwordTextSignal = passwordField.rac_textSignal().toSignalProducer()
            .flatMapError { error in
                return SignalProducer<AnyObject?, NoError>.empty
            }
            .map({ text -> String in
                return text as! String
            })
        
        // when login button is pressed
        let loginButtonSignal = loginButton.rac_signalForControlEvents(.TouchUpInside).toSignalProducer()
            .flatMapError { error in
                return SignalProducer<AnyObject?, NoError>.empty
        }
        
        let validEmailSignal = emailTextSignal
            .map { $0.isValidEmail }
        
        let validPasswordSignal = passwordTextSignal
            .map { $0.isValidPassword }
        
        emailField.rac_alpha <~ validEmailSignal
            .map { $0 ? 1.0 : 0.5 }
        
        passwordField.rac_alpha <~ validPasswordSignal
            .map { $0 ? 1.0 : 0.5 }
        
        // bind the result of signUpActiveSignal to the login button hidden property
        loginButton.rac_hidden <~ combineLatest(validEmailSignal, validPasswordSignal)
            .map { $0 && $1 }
            .map { !$0 }
        
        // login
        combineLatest(emailTextSignal, passwordTextSignal)
            .flatMapError { error in SignalProducer.empty }
            .sampleOn(loginButtonSignal.map { _ in () })
            .flatMap(.Latest) { (email, password) -> SignalProducer<Bool, NSError> in
                return self.apiClient.loginSignal(email, password: password)
                    .observeOn(UIScheduler())
                    .on(failed: { error -> () in
                        self.view.animateColor(UIColor.redColor())
                    })
                    .flatMapError { error -> SignalProducer<Bool, NSError> in
                        return SignalProducer.empty
                }
            }
            .observeOn(UIScheduler())
            .on(next: { loggedIn -> () in
                if loggedIn {
                    self.view.animateColor(UIColor.greenColor())
                } else {
                    self.emailField.shake()
                    self.passwordField.shake()
                }
            })
            .filter { $0 }
            .startWithNext { loggedIn -> () in
                print("done: load another controller")
        }
    }
}

