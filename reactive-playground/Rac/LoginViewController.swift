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

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let apiClient = ApiClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // when username text is changed
        let usernameTextSignal = usernameField.rac_textSignal().toSignalProducer()
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
        
        let validUsernameSignal = usernameTextSignal
            .map({ text -> Bool in
                self.isValidUsername(text)
            })
            
        let validPasswordSignal = passwordTextSignal
            .map({ text -> Bool in
                self.isValidPassword(text)
            })
        
        usernameField.rac_alpha <~ validUsernameSignal
            .map({ valid -> CGFloat in
                return valid ? 1.0 : 0.5
            })

        passwordField.rac_alpha <~ validPasswordSignal
            .map({ valid -> CGFloat in
                return valid ? 1.0 : 0.5
            })
        
        let signUpActiveSignal = combineLatest(validUsernameSignal, validPasswordSignal)
            .map({ (usernameValid, passwordValid) -> Bool in
                return usernameValid && passwordValid
            })
        
        // bind the result of signUpActiveSignal to the login button hidden property
        loginButton.rac_hidden <~ signUpActiveSignal
            .map({ signUpActive -> Bool in
                return !signUpActive
            })

        // login
        combineLatest(usernameTextSignal, passwordTextSignal)
            .flatMapError { error in
                return SignalProducer.empty
            }
            .sampleOn(loginButtonSignal.map { _ in () })
            .flatMap(FlattenStrategy.Latest) { (username, password) -> SignalProducer<Bool, NSError> in
                return self.apiClient.loginSignal(username, password: password)
            }
            .observeOn(UIScheduler())
            .on(next: { loggedIn -> () in
                    if loggedIn {
                        print("api: logged in")
                        self.view.animateColor(UIColor.greenColor())
                    } else {
                        print("api: invalid login credentials")
                        self.usernameField.shake()
                        self.passwordField.shake()
                    }
                }, failed: { error -> () in
                    self.view.animateColor(UIColor.redColor())
                })
            .filter({ loggedIn -> Bool in
                return loggedIn
            })
            .startWithNext { loggedIn -> () in
                print("done: load another controller")
            }
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    func isValidUsername(username: String) -> Bool {
        return username.characters.count > 3
    }
    
    func isValidPassword(password: String) -> Bool {
        return password.characters.count > 3
    }
}

