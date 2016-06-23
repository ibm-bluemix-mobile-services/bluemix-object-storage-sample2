//
//  FirstViewController.swift
//  bluemix-object-storage-sample2
//
//  Created by Conan Gammel on 6/22/16.
//  Copyright © 2016 Conan Gammel. All rights reserved.
//

import UIKit
import BluemixObjectStorage

class LoginViewController: UIViewController {
    
    var objectStore: ObjectStorage?
    internal var authToken: String = ""
    

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var indicateLogin: UIActivityIndicatorView!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func login(sender: AnyObject) {
        
        self.objectStore!.connect(userId:usernameText.text!, password:passwordText.text!, region: BluemixConsts.REGION_DALLAS, completionHandler:{ (error) in
            if error != nil{
                let alertController = UIAlertController(title: "Error", message:
                    "Your credentials did not succeed", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                //log error
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }else{
                self.indicateLogin.stopAnimating()
                //switch to public view
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disableLogin()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleBackgroundTap))
       
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.objectStore = ObjectStorage(projectId: BluemixConsts.ProjectId)
        if self.authToken.isEmpty{
            self.enableLogin()
        }else{
            self.objectStore!.connect(authToken, region:BluemixConsts.REGION_DALLAS, completionHandler:{ (error) in
                if error != nil{
                    let alertController = UIAlertController(title: "Error", message:
                        "Your Token Expire, Please Login", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.enableLogin()
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }else{
                    self.indicateLogin.stopAnimating()
                    //switch to public view
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func handleSuccessfulLogin() {
        
        self.indicateLogin.stopAnimating()
        
        let alert = UIAlertController(title: "", message: "Login succesfull", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewControllerWithIdentifier("PublicPhotoList") as! PublicPhotoListController
        let nav = UINavigationController.init(rootViewController: view)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = nav
    }
    

    
    func handleBackgroundTap(sender: UITapGestureRecognizer) {
        
        usernameText.resignFirstResponder()
        passwordText.resignFirstResponder()
    }
    
    func enableLogin(){
        self.indicateLogin.hidden = true
        self.indicateLogin.stopAnimating()
        self.usernameText.enabled = true
        self.passwordText.enabled = true
        self.loginButton.enabled = true
    }
    
    func disableLogin(){
        self.indicateLogin.hidden = false
        self.indicateLogin.startAnimating()
        self.usernameText.enabled = false
        self.passwordText.enabled = false
        self.loginButton.enabled = false
    }

    

}

