//
//  FirstViewController.swift
//  bluemix-object-storage-sample2
//
//  Created by Conan Gammel on 6/22/16.
//  Copyright © 2016 Conan Gammel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var indicateLogin: UIActivityIndicatorView!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func login(_ sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicateLogin.isHidden = false
        self.indicateLogin.startAnimating()
        self.usernameText.isEnabled = false
        self.passwordText.isEnabled = false
        self.loginButton.isEnabled = false
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector(("handleBackgroundTap")))
       
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func handleBackgroundTap(sender: UITapGestureRecognizer) {
        
        usernameText.resignFirstResponder()
        passwordText.resignFirstResponder()
    }

    

}

