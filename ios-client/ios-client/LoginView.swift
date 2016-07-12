//
//  LoginView.swift
//  ios-client
//
//  Created by adnan on 7/8/16.
//  Copyright © 2016 bluemix-mobile-experience. All rights reserved.
//

import UIKit
import BMSCore

class LoginView: UIViewController {
    
    let logger = Logger.logger(forName: "LoginViewController")
    
    var authDelegate: CustomAuthDelegate?
    var tabController: UITabBarController?

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func onLogin(sender: AnyObject) {
        if let username = self.usernameField.text, let password = self.passwordField.text{
            self.usernameField.resignFirstResponder()
            self.passwordField.resignFirstResponder()
            indicator.startAnimating()
            self.authDelegate?.submitCredentials(username, password: password)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicator.stopAnimating()
        Logger.sdkDebugLoggingEnabled = true
        
        let tapRecognizer = UITapGestureRecognizer(target:self, action: #selector(LoginView.handleBackgroundTap(_:)))
        
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func handleSuccessfulLogin() {
        performSegueWithIdentifier("returnSegue", sender: nil)
    }
    
    func handleUnsuccessfulLogin() {
        dispatchOnMainQueueAfterDelay(0) {
            self.indicator.stopAnimating()
            let alert = UIAlertController(title: "", message: "Login unsuccesfull", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func handleError() {
        let alert = UIAlertController(title: "", message: "An error occurred", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Destructive, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dispatchOnMainQueueAfterDelay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))+100
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func handleBackgroundTap(sender: UITapGestureRecognizer) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//    }
}
