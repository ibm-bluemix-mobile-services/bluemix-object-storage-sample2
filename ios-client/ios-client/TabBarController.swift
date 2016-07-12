//
//  TabBarController.swift
//  ios-client
//
//  Created by adnan on 7/8/16.
//  Copyright © 2016 bluemix-mobile-experience. All rights reserved.
//

import UIKit
import BMSCore
import BMSSecurity

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let mcaAuthManager = MCAAuthorizationManager.sharedInstance
    
    var authDelegate: CustomAuthDelegate?

    override func viewDidLoad() {
        BMSClient.sharedInstance.initializeWithBluemixAppRoute("https://sample-backend.mybluemix.net", bluemixAppGUID: "f6f5f5c0-ea83-43ca-8979-25f0071b06f6", bluemixRegion: BMSClient.REGION_US_SOUTH)
        BMSClient.sharedInstance.authorizationManager = MCAAuthorizationManager.sharedInstance
        mcaAuthManager.setAuthorizationPersistencePolicy(PersistencePolicy.NEVER)
        
        self.authDelegate = CustomAuthDelegate(tabBarController: self)
        let authenticationRealm = "sampleRealm"
        MCAAuthorizationManager.sharedInstance.registerAuthenticationDelegate(self.authDelegate!, realm: authenticationRealm)
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onAuthChallengeReceived(challenge:AnyObject){
        performSegueWithIdentifier("loginSegue", sender: nil)
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print(tabBarController.selectedIndex)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "loginSegue" {
            let loginView = segue.destinationViewController as! LoginView
            loginView.tabController = self
            loginView.authDelegate = self.authDelegate
            authDelegate?.loginView = loginView
        }
        print(segue.identifier)
    }
}
