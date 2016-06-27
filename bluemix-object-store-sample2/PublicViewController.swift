//
//  FirstViewController.swift
//  bluemix-object-store-sample2
//
//  Created by Conan Gammel on 6/24/16.
//  Copyright © 2016 Conan Gammel. All rights reserved.
//

import UIKit

class PublicViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBAction func addPictureFromCameraRoll(sender: AnyObject) {
        
    }
    
    @IBAction func addPictureFromNewPicture(sender: AnyObject) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cameraButton.enabled  = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

