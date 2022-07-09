//
//  ApplyJobViewController.swift
//  BrightOwl
//
//  Created by Khalid Usman on 5/4/16.
//  Copyright © 2016 Khalid Usman. All rights reserved.
//

import UIKit
import MediaPlayer
import Alamofire
import SwiftyJSON
import SVProgressHUD
import MobileCoreServices
import AssetsLibrary
import AVKit
import AVFoundation

class ApplyJobViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, APIResponseDelegates {

    @IBOutlet weak var _motivationLetter: UITextView!
    @IBOutlet weak var _applyButton: UIButton!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _movieView: UIView!
    
    var assetsLibrary = ALAssetsLibrary()
    
    var newStr = ""
    var titleStr = ""
    var kbHeight: CGFloat!
    var keyboardShowCount: CGFloat!
    
    var videoStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.titleView = UIImageView(image:UIImage(named: "navCenterLogo"))
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ApplyJobViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ApplyJobViewController.keyboardDidHide(_:)), name: UIKeyboardDidHideNotification, object: nil)
        
        keyboardShowCount = 0
        
        self._movieView.hidden = true
        self._motivationLetter.hidden = false
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self._titleLabel.text = "Write a motivation letter for " + self.titleStr
        //self.showVideo(NSURL(fileURLWithPath: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4") as NSURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickOnButton(button: UIButton) {
        let introVC = self.storyboard?.instantiateViewControllerWithIdentifier("introVC")
        self.navigationController?.pushViewController(introVC!, animated: true)
    }
    
    //MARK:- UIText View
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    //MARK:- keyboard Attribute
    
    func keyboardDidShow(sender: NSNotification) {
        
        if self.keyboardShowCount==0 {
            keyboardShowCount = keyboardShowCount+1
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 where value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            switch identifier {
            case "iPhone4,1":
                UIView.animateWithDuration(0.3, animations: {
                    self.view.frame = CGRectOffset(self.view.frame, 0, -40)
                })
            case "i386", "x86_64":
                UIView.animateWithDuration(0.3, animations: {
                    self.view.frame = CGRectOffset(self.view.frame, 0, -40)
                })
            default:
                print("Do Nothing!")
            }
        }
    }
    
    func keyboardDidHide(sender: NSNotification) {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPhone4,1":
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, self.keyboardShowCount*40)
            })
        case "i386", "x86_64":
            UIView.animateWithDuration(0.3, animations: {
                self.view.frame = CGRectOffset(self.view.frame, 0, self.keyboardShowCount*40)
            })
        default:
            print("Do Nothing!")
        }
        self.keyboardShowCount = 0
    }
    
    //MARK:- Apply for job
    
    @IBAction func ApplyForJobBtn(sender: AnyObject) {
        if (isConnectedToNetwork()==true) {
            let expertId = NSUserDefaults.standardUserDefaults().stringForKey("expert_id");
            let id = self.newStr
            let motivation = _motivationLetter.text
            
            if (self.videoStr.isEmpty == false) {
                SVProgressHUD.showWithStatus("Loading...")
                let preUrl: String = "expert/"
                let postUrl: String = "/apply"
                let urlString = "http://brightowl.xorlogics.com/dev/api/" + String(format: "%@%@%@", preUrl, expertId!, postUrl)
                let appKey = "app_key=ios-app,app_secret=ios-app-key"
                let auth_token : String = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as! String
                var parameters = [String: AnyObject]()
                parameters["project_id"] = id
                parameters["motivation_text"] = motivation
                let header = [
                    "App": appKey,
                    "AuthToken": auth_token
                ]
                Alamofire.upload(
                    .POST,
                    urlString,
                    headers: header,
                    multipartFormData: { multipartFormData in
                        multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: self.videoStr), name: "motivation_video")
                        for (key, value) in parameters {
                            multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                        }
                    },
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON { response in
                                SVProgressHUD.dismiss()
                                let alert = UIAlertController(title: "", message: "You have applied Successfully!", preferredStyle: .Alert);
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                    
                                    var stack = self.navigationController!.viewControllers as Array
                                    if stack[stack.count-2] is SaveJobViewController {
                                        self.navigationController?.popViewControllerAnimated(true)
                                    }
                                    else {
                                        // parentVC is anotherViewController
                                        self.navigationController?.popToRootViewControllerAnimated(true)
                                    }
                                }))
                                self.presentViewController(alert, animated: true, completion:nil)
                            }
                        case .Failure(let encodingError):
                            print(encodingError)
                            SVProgressHUD.dismiss()
                            Utility.displayMessage("You are failed to apply!")
                        }
                    }
                )
            }
            else {
                var dicCridantials = [String: AnyObject]()
                dicCridantials["project_id"] = id
                dicCridantials["motivation_text"] = motivation
                do {
                    SVProgressHUD.showWithStatus("Loading...")
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(dicCridantials, options: NSJSONWritingOptions.PrettyPrinted)
                    let preUrl: String = "expert/"
                    let postUrl: String = "/apply"
                    let urlString = String(format: "%@%@%@", preUrl, expertId!, postUrl)
                    API.postRequest(urlString, jsonData: jsonData, isLogin: true, delegate: self)
                }
                catch let error as NSError {
                    print(error)
                }
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    @IBAction func CancelJobBtn(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: UIImagePickerController
    
    func showVideo(url : NSURL) {
        let theSubviews : Array<UIView> = self.view.subviews as Array<UIView>
        for view in theSubviews {
            if view.isKindOfClass(AVPlayerViewController) {
                view.removeFromSuperview()
            }
        }
        let player = AVPlayer(URL:url)
        let av = AVPlayerViewController()
        av.player = player
        av.view.frame = self._movieView.frame
        self.addChildViewController(av)
        self.view.addSubview(av.view)
        av.didMoveToParentViewController(self)
        
        self._motivationLetter.hidden = true
        self._movieView.hidden = false
        
        self._titleLabel.text = "Motivation video for " + self.titleStr
    }
    
    @IBAction func recordVideoPressed(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil {
                
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.videoMaximumDuration = 60.0
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
                imagePicker.delegate = self
                
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                Utility.displayMessage("Application cannot access the camera.")
            }
        } else {
            Utility.displayMessage("Application cannot access the camera.")
        }
    }
    
    @IBAction func uploadVideoPressed(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // Finished recording a video
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
        
        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                    self.videoStr = (urlOfVideo?.path)!
                    if let url = urlOfVideo {
                        assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(url,
                                                                         completionBlock: {(url: NSURL!, error: NSError!) in
                                                                            if let theError = error{
                                                                                print("Error saving video = \(theError)")
                                                                            }
                                                                            else {
                                                                                print("no errors happened")
                                                                            }
                                                                            self.showVideo(urlOfVideo!)
                        })
                    }
                } 
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:- API Response Delegates
    
    func apiSuccessResponseWithURL(json: JSON, urlString : String) {
        SVProgressHUD.dismiss()
        let alert = UIAlertController(title: "", message: "You have applied Successfully!", preferredStyle: .Alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            var stack = self.navigationController!.viewControllers as Array
            if stack[stack.count-2] is SaveJobViewController {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                // parentVC is anotherViewController
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }))
        self.presentViewController(alert, animated: true, completion:nil)
    }
    
    func apiFailureResponseWithURL(errorDesc: String, urlString: String) {
        SVProgressHUD.dismiss()
        print("Failed \(errorDesc)")
        Utility.displayMessage("Fail to apply")
    }
}
