//
//  LoginViewController.swift
//  bluemix-object-store-sample2
//
//  Created by Conan Gammel on 6/24/16.
//  Copyright © 2016 Conan Gammel. All rights reserved.
//

import UIKit
import BMSCore
import BMSSecurity

class LoginViewController : UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    let customRealm = "<realmName>"
    let mcaAuthManager = MCAAuthorizationManager.sharedInstance
    let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var authDelegate: MyAuthDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        Logger.sdkDebugLoggingEnabled = true
        
        self.usernameField.enabled = false
        self.passwordField.enabled = false
        self.loginButton.enabled = false
        
        let tapRecognizer = UITapGestureRecognizer(target:self, action: #selector(LoginViewController.handleBackgroundTap(_:)))
        
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.authDelegate = MyAuthDelegate(loginViewController: self)
        
        MCAAuthorizationManager.sharedInstance.registerAuthenticationDelegate(self.authDelegate!, realm: customRealm)
        
    }
    
    func onAuthChallengeReceived(challenge:AnyObject){
        
        self.usernameField.enabled = true
        self.passwordField.enabled = true
        self.loginButton.enabled = true
        
        self.performSelectorOnMainThread(#selector(LoginViewController.loadView), withObject: nil, waitUntilDone: true)
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: AnyObject) {
        self.usernameField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        self.authDelegate?.submitCredentials(username!, password: password!)
    }
    
    func handleBackgroundTap(sender: UITapGestureRecognizer) {
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    func handleSuccessfulLogin() {
        
        let alert = UIAlertController(title: "", message: "Login succesfull", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewControllerWithIdentifier("PrivatePhotos") as! PrivateViewController
        let nav = UINavigationController.init(rootViewController: view)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = nav
    }
    
    func handleUnsuccessfulLogin() {
        
        let alert = UIAlertController(title: "", message: "Login unsuccesfull", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleError() {
        
        let alert = UIAlertController(title: "", message: "An error occurred", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Destructive, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }


}