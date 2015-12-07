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
            .map({ text -> Bool in
                return text.isValidEmail
            })
            
        let validPasswordSignal = passwordTextSignal
            .map({ text -> Bool in
                return text.isValidPassword
            })
        
        emailField.rac_alpha <~ validEmailSignal
            .map({ valid -> CGFloat in
                return valid ? 1.0 : 0.5
            })

        passwordField.rac_alpha <~ validPasswordSignal
            .map({ valid -> CGFloat in
                return valid ? 1.0 : 0.5
            })
        
        let signUpActiveSignal = combineLatest(validEmailSignal, validPasswordSignal)
            .map({ (emailValid, passwordValid) -> Bool in
                return emailValid && passwordValid
            })
        
        // bind the result of signUpActiveSignal to the login button hidden property
        loginButton.rac_hidden <~ signUpActiveSignal
            .map({ signUpActive -> Bool in
                return !signUpActive
            })

        // login
        combineLatest(emailTextSignal, passwordTextSignal)
            .flatMapError { error in
                return SignalProducer.empty
            }
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
                        print("api: logged in")
                        self.view.animateColor(UIColor.greenColor())
                    } else {
                        print("api: invalid login credentials")
                        self.emailField.shake()
                        self.passwordField.shake()
                    }
                })
            .filter({ loggedIn -> Bool in
                return loggedIn
            })
            .startWithNext { loggedIn -> () in
                print("done: load another controller")
            }
    }
}

