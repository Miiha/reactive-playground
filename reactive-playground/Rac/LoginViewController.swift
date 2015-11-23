//
//  ViewController.swift
//  Rac
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

        let usernameTextSignal = usernameField.rac_textSignal().toSignalProducer()
            .flatMapError { error in
                return SignalProducer<AnyObject?, NoError>.empty
            }
            .map({ text -> String in
                return text as! String
            })
        
        let passwordTextSignal = passwordField.rac_textSignal().toSignalProducer()
            .flatMapError { error in
                return SignalProducer<AnyObject?, NoError>.empty
            }
            .map({ text -> String in
                return text as! String
            })
  
//        usernameTextSignal.startWithNext { text -> () in
//            print("usernameTextSignal", text)
//        }
        
//        passwordTextSignal.startWithNext { text -> () in
//            print("passwordTextSignal", text)
//        }
        
        let validUsernameSignal = usernameTextSignal
            .map { text -> Bool in
                return self.isValidUsername(text)
            }

        let validPasswordSignal = passwordTextSignal
            .map { text -> Bool in
                return self.isValidPassword(text)
            }
        
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
        
        // bind the result of signUpActiveSignal to the login button
        loginButton.rac_hidden <~ signUpActiveSignal.map {!$0}

        let loginSignal = loginButton.rac_signalForControlEvents(.TouchUpInside).toSignalProducer()
            .flatMapError { error in
                return SignalProducer<AnyObject?, NoError>.empty
            }
            .ignoreNil()
        
        validPasswordSignal
            .sampleOn(loginSignal.map {_ in ()})
            .filter { !$0 }
            .startWithNext { next -> () in
                self.passwordField.shake()
            }

        validUsernameSignal
            .sampleOn(loginSignal.map { _ in ()})
            .filter { !$0 }
            .startWithNext { next -> () in
                self.usernameField.shake()
        }
        
        combineLatest(usernameTextSignal, passwordTextSignal)
            .flatMapError { error in
                return SignalProducer.empty
            }
            .sampleOn(loginSignal.map({ event -> Void in
                return ()
                })
            )
            .flatMap(FlattenStrategy.Latest) { (username, password) -> SignalProducer<Bool, NSError> in
                return self.apiClient.loginSignal(username, password: password)
                    .retry(1)
                    .observeOn(UIScheduler())
                    .on(failed: { error -> () in
                        self.view.animateColor(UIColor.redColor())
                    })
                    .flatMapError { error in
                        return SignalProducer.empty
                    }
            }
            .observeOn(UIScheduler())
            .on(next: { loggedIn -> () in
                if !loggedIn {
                    print("invalid login credentials")
                    self.usernameField.shake()
                    self.passwordField.shake()
                }
            })
            .filter { $0 }
            .startWithNext { loggedIn -> () in
                self.view.animateColor(UIColor.greenColor())
                print("logged in")
            }
    }
    
    func isValidUsername(username: String) -> Bool {
        return username.characters.count > 3
    }
    
    func isValidPassword(password: String) -> Bool {
        return password.characters.count > 3
    }
}

