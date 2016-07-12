/*
 *     Copyright 2016 IBM Corp.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 */

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
