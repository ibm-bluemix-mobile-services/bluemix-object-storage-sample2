//
//  MyAuthDelegate.swift
//  bluemix-object-store-sample2
//
//  Created by Conan Gammel on 6/28/16.
//  Copyright © 2016 Conan Gammel. All rights reserved.
//

import Foundation
import UIKit
import BMSCore
import BMSSecurity

class MyAuthDelegate: AuthenticationDelegate {
    
    let logger = Logger.logger(forName: "MyAuthDelegate")
    
    let loginViewController: LoginViewController
    var authContext: AuthenticationContext?
    
    init(loginViewController: LoginViewController) {
        
        self.loginViewController = loginViewController;
    }
    
    func submitCredentials(username:String, password: String){
        
        guard let authContext = authContext else {
            
            return
        }
        let challengeAnswer:[String:AnyObject] = ["username":username, "password":password]
        authContext.submitAuthenticationChallengeAnswer(challengeAnswer)
    }
    
    func onAuthenticationChallengeReceived(authContext: AuthenticationContext, challenge: AnyObject){
        
        print("received authentication challenge")
        
        self.authContext = authContext
        self.loginViewController.onAuthChallengeReceived(challenge)
    }
    
    func onAuthenticationSuccess(info: AnyObject?) {
        
        print("authentication successed. received info: \(info)")
        
        let attributes = info!["attributes"]
        let token = attributes!!["token"]
        
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(token, forKey: "token")
        
        loginViewController.performSelectorOnMainThread(#selector(loginViewController.handleSuccessfulLogin), withObject: nil, waitUntilDone: false)
    }
    
    func onAuthenticationFailure(info: AnyObject?){
        
        print("authenticaton failured. received info: \(info)")
        
        loginViewController.performSelectorOnMainThread(#selector(loginViewController.handleUnsuccessfulLogin), withObject: nil, waitUntilDone: false)
    }
    
}