//
//  CustomAuthDelegate.swift
//  ios-client
//
//  Created by adnan on 7/8/16.
//  Copyright © 2016 bluemix-mobile-experience. All rights reserved.
//

import Foundation
import BMSCore
import BMSSecurity

class CustomAuthDelegate: AuthenticationDelegate {
    let logger = Logger.logger(forName: "MyAuthDelegate")
    
    var tabBarController: TabBarController?
    var loginView: LoginView?
    var authContext: AuthenticationContext?
    
    init(tabBarController: TabBarController) {
        self.tabBarController = tabBarController
    }
    
    func submitCredentials(username:String, password: String) {
        
        guard let authContext = authContext else {
            return
        }
        
        let challengeAnswer:[String:AnyObject] = ["username":username, "password":password]
        authContext.submitAuthenticationChallengeAnswer(challengeAnswer)
    }
    
    func onAuthenticationChallengeReceived(authContext: AuthenticationContext, challenge: AnyObject) {
        
        logger.debug("received authentication challenge")
        
        self.authContext = authContext
        self.tabBarController!.onAuthChallengeReceived(challenge)
    }
    
    func onAuthenticationSuccess(info: AnyObject?) {
        
        logger.debug("authentication successed. received info: \(info)")
        self.loginView?.handleSuccessfulLogin()
    }
    
    func onAuthenticationFailure(info: AnyObject?) {
        logger.debug("authenticaton failured. received info: \(info)")
        self.loginView?.handleUnsuccessfulLogin()
    }
    
}
