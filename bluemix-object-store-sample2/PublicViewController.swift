//
//  FirstViewController.swift
//  bluemix-object-store-sample2
//
//  Created by Conan Gammel on 6/24/16.
//  Copyright © 2016 Conan Gammel. All rights reserved.
//

import UIKit
import BMSCore
import BMSSecurity

class PublicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let logger = Logger.logger(forName: "PhotoListController")
    let theFuture = NSDate.distantFuture().timeIntervalSince1970
    let ObjectStorageEndpoint = "public"
    
    var objectStoreResource: HttpResource?
    var listOfObjects: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.objectStoreResource = HttpResource(schema:Consts.ObjectStorageScheme, host: Consts.ObjectStorageHost, port: Consts.ObjectStoragePort, path: ObjectStorageEndpoint)
        cameraButton.enabled  = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        
//        HttpClient.get(resource: self.objectStoreResource!, headers: nil, completionHandler: {(error, status, headers, data) in
//            if error != nil{
//                self.logger.debug("Get public object list threw error: \(error)")
//            }
//            self.displayObjects(data!)
//        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addPictureFromCameraRoll(sender: AnyObject) {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func addPictureFromNewPicture(sender: AnyObject) {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func displayObjects(objects: NSData){
        //parse array of names,
        //GET the data,
        //put into uiImageViewer
    }


    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let now = NSDate().timeIntervalSince1970
        let imageName = (theFuture - now) * 1000
        
        HttpClient.put(resource: self.objectStoreResource!.resourceByAddingPathComponent(pathComponent: "\(imageName)"), headers: nil, data: UIImageJPEGRepresentation(image, 0.7)!, completionHandler: { (error, status, headers, data) in
            if let error = error {
                self.logger.error("The following error occurred while loading an image into the object storage service: \(error)")
            } else {
                //refresh images
            }
        })
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}

