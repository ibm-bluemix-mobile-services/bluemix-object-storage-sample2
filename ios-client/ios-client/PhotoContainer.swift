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

import UIKit
import BMSCore
import BMSSecurity
import SwiftyJSON

class PhotoContainer: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let logger = Logger.logger(forName: "PhotoContainer")
    
    let defaultCellHeight = 265.0
    let theFuture = NSDate.distantFuture().timeIntervalSince1970
    
    var resourceUrl = "http://localhost:10010"
    var path: String?
    var tableTitle: String?
    
    var logoutButton: UIBarButtonItem?
    var addButton: UIBarButtonItem?
    var deleteButton: UIBarButtonItem?
    var tapRecognizer: UITapGestureRecognizer?
//    var swipeRecognizer: UISwipeGestureRecognizer?
    
    var objectList: [String] = []
    var contentCache: [String : UIImage] = [:]
    
    
    override func viewDidLoad() {
        self.path = (self.restorationIdentifier == "publicContainer") ? "/public" : "/private"
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.backgroundTap(_:)))
//        self.swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.refreshTableView(_:)))
//        self.swipeRecognizer?.direction = .Down
//        self.swipeRecognizer?.enabled = true
        self.logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(self.logout(_:)))
        self.addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addToContainer(_:)))
        self.deleteButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(self.deleteFromContainer(_:)))
        self.refreshControl?.addTarget(self, action: #selector(self.refreshTableView(_:)), forControlEvents: .ValueChanged)
        self.refreshControl?.enabled = true
        self.view.addGestureRecognizer(tapRecognizer!)
//        self.view.addGestureRecognizer(swipeRecognizer!)
        
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.refreshTableView(nil)
        self.tableTitle = (self.restorationIdentifier == "publicContainer") ? "Shared" : "My Album"
        self.navigationItem.leftBarButtonItem = (self.restorationIdentifier == "privateContainer") ? self.logoutButton : nil
        self.navigationItem.title = title
        
        if objectList.isEmpty {
            self.navigationItem.rightBarButtonItems?.removeAll()
        }
        else {
            self.navigationItem.rightBarButtonItems = [self.addButton!]
        }
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let key = self.objectList[row]
        let cell = tableView.dequeueReusableCellWithIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCell
        
        cell.customImageView.image = nil
        cell.customImageView.userInteractionEnabled = false
        cell.indicator.startAnimating()
        
        if contentCache.indexForKey(key) != nil {
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
            
            cell.indicator.stopAnimating()
            cell.customImageView.image = contentCache[key]
            cell.customImageView.addGestureRecognizer(longPressRecognizer)
            cell.customImageView.userInteractionEnabled = true
        }
        else {
            let name = self.objectList[row]
            let url = self.resourceUrl + self.path! + "/" + name
            let request = Request(url: url, method: .GET)
            
            request.sendWithCompletionHandler({ (response, error) in
                guard let response = response else {
                    return
                }
                guard response.statusCode == 200 else {
                    self.dispatchOnMainQueueAfterDelay(0) {
                        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: .Right)
                    }
                    return
                }
                guard let data = response.responseData else {
                    return
                }
                let image = UIImage(data: data)
                self.contentCache[key] = image!
                self.dispatchOnMainQueueAfterDelay(10) {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            })
        }

        return cell
    }
    
    func logout(sender: AnyObject?) {
        (self.tabBarController as! TabBarController).mcaAuthManager.logout { (response, error) in
            if let error = error {
                self.logger.error("Error received while logging out: \(error)")
            }
            self.deleteRows(Set(self.objectList))
            self.dispatchOnMainQueueAfterDelay(0) {
                let index = ((self.tabBarController?.selectedIndex)! + 1) % 2
                self.tabBarController?.selectedIndex = index
            }
        }
    }
    
    func refreshTableView(refreshControl: UIRefreshControl?) {
        let url = self.resourceUrl + self.path!
        let request = Request(url: url, method: HttpMethod.GET)
        
        request.sendWithCompletionHandler { (response, error) in
            if let error = error {
                self.logger.error("Error received fetching contents of container at \(self.resourceUrl + self.path!): \(error)")
            }
            else {
                guard let response = response else {
                    return
                }
                let status = response.statusCode
                guard status == 200 else {
                    var alert: UIAlertController
                    
                    if status == 404 {
                        alert = UIAlertController(title: "", message: "Could not locate container", preferredStyle: .Alert)
                    }
                    else {
                        alert = UIAlertController(title: "", message: "An error ocurred while getting the contents of the container", preferredStyle: .Alert)
                    }
                    alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    return
                }
                let data = response.responseData
                self.setupTableView(data!)
            }
        }
        if let refreshControl = refreshControl {
            refreshControl.endRefreshing()
        }
    }
    
    func setupTableView(containerContents: NSData) {
        let json = JSON(data: containerContents)
        var names: [String] = []
        
        for (index, object):(String, JSON) in json {
            names.insert(object["name"].stringValue, atIndex: Int(index)!)
        }
        if names == self.objectList {
            return
        }
        let oldSet = Set(self.objectList)
        let newSet = Set(names)
        let deleteDifference = oldSet.subtract(newSet)
        let insertDifference = newSet.subtract(oldSet)
        
        self.deleteRows(deleteDifference)
        self.insertRows(insertDifference, list: names)
        self.dispatchOnMainQueueAfterDelay(0) {
            self.tableView.reloadData()
            self.addButton?.enabled = true
            self.navigationItem.rightBarButtonItems = [self.addButton!]
        }
    }
    
    func insertRows(set: Set<String>, list: Array<String>) {
        if set.count == 0 {
            return
        }
        var indexPaths: [NSIndexPath] = []
        let elementsToInsert = set.sort()
        
        for element in elementsToInsert {
            let index = list.indexOf(element)
            self.objectList.insert(element, atIndex: index!)
            indexPaths.append(NSIndexPath(forRow: (self.objectList.count - 1), inSection: 0))
        }
        self.dispatchOnMainQueueAfterDelay(0) {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Left)
        }
    }
    
    func deleteRows(set: Set<String>) {
        if set.count == 0{
            return
        }
        var indexPaths: [NSIndexPath] = []
        
        for element in set {
            let index = self.objectList.indexOf(element)
            self.objectList.removeAtIndex(index!)
            self.contentCache.removeValueForKey(element)
            indexPaths.append(NSIndexPath(forRow: self.objectList.count, inSection: 0))
        }
        self.dispatchOnMainQueueAfterDelay(0) {
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
        }
    }
    
    func backgroundTap(recognizer: UITapGestureRecognizer) {
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            return
        }
        self.navigationItem.rightBarButtonItems = [self.addButton!]
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationItem.title = self.tableTitle!
    }
    
    func longPress(recognizer: UILongPressGestureRecognizer?) {
        let view = recognizer?.view as! UIImageView
        let keys = (contentCache as NSDictionary).allKeysForObject(view.image!)
        let key = keys[0]
        let row = self.objectList.indexOf(key as! String)
        let indexPath = NSIndexPath(forRow: row!, inSection: 0)
        
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        self.navigationItem.rightBarButtonItems = [self.deleteButton!]
        self.navigationItem.title = (key as! String)
    }
    
    func addToContainer(sender: AnyObject?) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let alert = UIAlertController(title: "", message: "Where would you like to upload a photo from?", preferredStyle: .ActionSheet)
            
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (alertAction) in
                self.addFromCamera()
            }))
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (alertAction) in
                self.addFromPhotoLibrary()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.addFromPhotoLibrary()
        }
    }
    
    func deleteFromContainer(image: UIImage?) {
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            return
        }
        let imageName = objectList[indexPath.row]
        
        self.deleteImage(imageName)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addToContainer(_:)))
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func store(image: NSData, withName: String) {
        let url = self.resourceUrl + self.path! + "/" + withName
        let request = Request(url: url, headers: ["Content-Type" : "image/jpeg"], queryParameters: nil, method: .PUT)
        
        request.sendData(image) { (response, error) in
            guard let response = response else {
                return
            }
            if response.statusCode != 200 {
                let alert = UIAlertController(title: "", message: "An error ocurred while uploading \(withName)", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                self.refreshTableView(nil)
            }
        }
    }
    
    func deleteImage(withName: String) {
        let url = self.resourceUrl + self.path! + "/" + withName
        let request = Request(url: url, method: .DELETE)
        
        request.sendWithCompletionHandler { (response, error) in
            guard let response = response else {
                return
            }
            let status = response.statusCode
            if status != 200 {
                var alert: UIAlertController
                
                if status == 404 {
                    alert = UIAlertController(title: "", message: "Unable to locate \(withName)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .Destructive, handler: { (alertAction) in
                        let index = self.objectList.indexOf(withName)
                        self.deleteRows(Set([self.objectList[index!]]))
                    }))
                }
                else {
                    alert = UIAlertController(title: "", message: "An error ocurred while deleting \(withName)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
                }
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                self.refreshTableView(nil)
            }
        }
        
    }
    
    func addFromPhotoLibrary() {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    func addFromCamera() {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageContent = UIImageJPEGRepresentation(image, 0.5)!
        let now = NSDate().timeIntervalSince1970
        let imageName = Int((theFuture - now) * 1000)
        
        store(imageContent, withName: "\(imageName).jpg")
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dispatchOnMainQueueAfterDelay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))+100
            ),
            dispatch_get_main_queue(), closure)
    }
}
