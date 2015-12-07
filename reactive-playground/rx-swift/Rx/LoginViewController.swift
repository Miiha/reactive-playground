//
//  ViewController.swift
//  Reactive Playground
//
//  Created by Michael Kao on 06/11/15.
//  Copyright © 2015 Michael Kao. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let apiClient = ApiClient()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.disposeBag = DisposeBag()
        
        let validEmailObservable = emailField.rx_text
            .map { $0.isValidEmail }
            .shareReplay(1)
        
        let validPasswordObservable = passwordField.rx_text
            .map { $0.isValidPassword }
            .shareReplay(1)

        validEmailObservable
            .map { $0 ? 1.0 : 0.5 }
            .bindTo(emailField.rx_alpha)
            .addDisposableTo(disposeBag)
        
        validPasswordObservable
            .map { $0 ? 1.0 : 0.5 }
            .bindTo(passwordField.rx_alpha)
            .addDisposableTo(disposeBag)
        
        let signupEnabled = combineLatest(validEmailObservable, validPasswordObservable) { $0 && $1 }
        
        signupEnabled
            .map { !$0 }
            .bindTo(loginButton.rx_hidden)
            .addDisposableTo(disposeBag)
        
        combineLatest(emailField.rx_text, passwordField.rx_text) { ($0, $1) }
            .sampleLatest(loginButton.rx_tap)
            .map { (username, password) in
                return self.apiClient.loginObservable(username, password: password)
                        .observeOn(MainScheduler.sharedInstance)
                        .doOn(onError: { (error) -> Void in
                            self.view.animateColor(UIColor.redColor())
                        })
                        .catchError { error in
                            return empty()
                        }
            }
            .switchLatest()
            .observeOn(MainScheduler.sharedInstance)
            .doOn(onNext: { loggedIn -> Void in
                if loggedIn {
                    self.view.animateColor(UIColor.greenColor())
                } else {
                    self.emailField.shake()
                    self.passwordField.shake()
                }
            })
            .filter { $0 }
            .subscribeNext({ loogedIn -> Void in
                print("done: load another controller")
            })
            .addDisposableTo(disposeBag)
    }
}

