//
//  TabController.swift
//  bluemix-object-store-sample2
//
//  Created by Conan Gammel on 6/27/16.
//  Copyright © 2016 Conan Gammel. All rights reserved.
//

import Foundation
import UIKit

class TabController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
    }
    
    // UITabBarDelegate
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.title! == "Private"{
            //MAY NEED TO DELETE THE RELATIONSHIP TO SHOW PRIVATE PAGE
        //      if !loggedIn(){
        //          ShowLoginViewController
        //      }else{
        //          show privatepages
        //      }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        let nav = UINavigationController.init(rootViewController: view)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = nav
        
        print("\(item.title!)")
    }

}