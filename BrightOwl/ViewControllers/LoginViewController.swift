//
//  LoginViewController.swift
//  BrightOwl
//
//  Created by Khalid Usman on 4/19/16.
//  Copyright © 2016 Khalid Usman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
class LoginViewController: UIViewController, UITextFieldDelegate, APIResponseDelegates {

    @IBOutlet weak var _loginView: UIView!
    @IBOutlet weak var _passwordView: UIView!
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _bottomImageView: UIImageView!
    @IBOutlet weak var _emailTextfield: UITextField!
    @IBOutlet weak var _passwordTextfield: UITextField!
    @IBOutlet weak var _loginButton: UIButton!
    @IBOutlet weak var _rememberButton: UIButton!
    @IBOutlet weak var _forgetButton: UIButton!
    @IBOutlet weak var _rememberLabel: UILabel!
    
    var codeTextField: UITextField?;
    var keyboardShowCount: CGFloat!
    
    //MARK:- UIViewControllerLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._loginView.layer.cornerRadius = 5;
        self._loginView.layer.masksToBounds = true;
        self._passwordView.layer.cornerRadius = 5;
        self._passwordView.layer.masksToBounds = true;
        self._loginButton.layer.cornerRadius = self._loginButton.bounds.size.height/2
        self._loginButton.layer.masksToBounds = true;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardDidShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardDidHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        keyboardShowCount = 0
        
        _emailTextfield.attributedPlaceholder = NSAttributedString(string:"Username",attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        _passwordTextfield.attributedPlaceholder = NSAttributedString(string:"Password",attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        self.setFonts()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
//        let screenSize: CGRect = UIScreen.mainScreen().bounds
//        if (screenSize.height<500) {
//            self._bottomImageView.frame = CGRectMake(0, screenSize.height-120, screenSize.width, 120)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Set Fonts
    
    func setFonts() {
        
        var loginRegularFont = UIFont(name: "Lato-Regular", size: 16)
        var loginBoldFont = UIFont(name: "Lato-Bold", size: 16)
        var forgetRegularFont = UIFont(name: "Lato-Regular", size: 13)
        
        if (Utility.getDevice() == "iPad") {
            loginRegularFont = UIFont(name: "Lato-Regular", size: 22)
            loginBoldFont = UIFont(name: "Lato-Bold", size: 22)
            forgetRegularFont = UIFont(name: "Lato-Regular", size: 17)
        }
        self._emailTextfield.font = loginRegularFont
        self._passwordTextfield.font = loginRegularFont
        self._loginButton.titleLabel?.font = loginBoldFont
        self._rememberLabel.font = forgetRegularFont
        self._forgetButton.titleLabel?.font = forgetRegularFont
    }
    
    //MARK:- Keyboard Show/Hide
    
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
    
    //MARK:- UITextField Delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    //MARK:- Email Validation
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(testStr);
    }
    
    //MARK:- Login
    
    func doLogin(email : String, password : String) {
        if (isConnectedToNetwork()==true) {
            var dicCridantials = [String: AnyObject]()
            dicCridantials["email"] = email
            dicCridantials["password"] = password
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(dicCridantials, options: NSJSONWritingOptions.PrettyPrinted)
                SVProgressHUD.showWithStatus("Loading...")
                API.postRequest("authenticate", jsonData: jsonData, isLogin: true, delegate: self)
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    @IBAction func btnLoginPressed(sender: AnyObject) {
        
        let userEmail = _emailTextfield.text
        let userPassword = _passwordTextfield.text
        if (userEmail!.isEmpty || userPassword!.isEmpty) {
            Utility .displayMessage("User Email or Password is Empty")
            return;
        }
        else if isValidEmail(userEmail!) {
            self._emailTextfield.resignFirstResponder()
            self._passwordTextfield.resignFirstResponder()
            doLogin(userEmail!, password: userPassword!)
        }
        else {
            Utility.displayMessage("Email is not valid")
        }
    }
    
    @IBAction func btnForgetPasswordPressed(sender: AnyObject) {
        
        let alert = UIAlertController(title: "", message: "Enter your email!", preferredStyle: .Alert);
        var titleTextField: UITextField?
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            titleTextField = textField
            titleTextField?.borderStyle = UITextBorderStyle.None
            var headlineFont = UIFont(name: "HelveticaNeue", size: 13)
            if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
                headlineFont = UIFont(name: "HelveticaNeue", size: 18)
            }
            titleTextField?.font = headlineFont
        }
        titleTextField?.placeholder = "Email"
        let cancel = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.Default,handler:nil);
        alert.addAction(cancel);
        alert.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            if (titleTextField?.text?.isEmpty == true) {
                Utility.displayMessage("User email or password is empty");
                return;
            }
            else {
                self.resetPassword((titleTextField?.text)!)
            }
        }))
        self.presentViewController(alert, animated: true, completion:nil)
    }
    
    func resetPassword(email : String) {
        if (isConnectedToNetwork()==true) {
            if isValidEmail(email) {
                let parameters = ["email": email]
                do {
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
                    SVProgressHUD.showWithStatus("Loading...")
                    API.postRequest("forgot-password", jsonData: jsonData, isLogin: true, delegate: self)
                }
                catch let error as NSError {
                    print(error)
                }
            }
            else {
                Utility.displayMessage("Email is not valid")
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    @IBAction func btnRememberMePressed(sender: AnyObject) {
        if(sender.imageView!!.image == UIImage(named:"checkbox_check")) {
            self._rememberButton.setImage(UIImage(named:"checkbox_uncheck"), forState: UIControlState.Normal)
        }
        else {
            self._rememberButton.setImage(UIImage(named:"checkbox_check"), forState: UIControlState.Normal)
        }
    }
    
    //MARK:- UIAlert
    
    func displayMessage(UserMessage:String) {
        let myAlert = UIAlertController(title: "Alert", message: UserMessage, preferredStyle: UIAlertControllerStyle.Alert);
        let OkAction = UIAlertAction(title: "OK", style:UIAlertActionStyle.Default,handler:nil);
        myAlert.addAction(OkAction);
        self.presentViewController(myAlert, animated: true, completion:nil)
    }
    
    //MARK:- UIImage Download
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        }
        else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func downloadImage(url: NSURL) {
        //SVProgressHUD.showWithStatus("Loading...")
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                let myImageName = "profile_Pic.png"
                let imagePath = self.fileInDocumentsDirectory(myImageName)
                let image = self.cropToBounds(UIImage(data:  data)!, width: 80, height: 80)
                let pngImageData = UIImagePNGRepresentation(image)
                pngImageData!.writeToFile(imagePath, atomically: true)
                
                SVProgressHUD.dismiss()
                
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let mainNav = mainStoryboard.instantiateViewControllerWithIdentifier("mainNav") as! UINavigationController
                appDelegate.window?.rootViewController = mainNav
                appDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    //MARK:- API Response Delegates
    
    func apiSuccessResponseWithURL(json: JSON, urlString : String) {
        let statusString = json["status"].stringValue
        if urlString.containsString("forgot-password") {
            let responseStr = json["response"].stringValue
            SVProgressHUD.dismiss()
            Utility.displayMessage(responseStr)
        }
        else if (statusString == "350" || statusString == "403") {
            SVProgressHUD.dismiss()
            Utility.displayMessage("Email Password Mismatch");
            return;
        }
        else {
            let responseUser: Dictionary<String, JSON> = json["response"].dictionaryValue
            let auth_Token = responseUser["auth_token"]!.stringValue
            let responseExpert: Dictionary<String, JSON> = responseUser["expert"]!.dictionaryValue
            let expert_Id = responseExpert["expert_id"]!.stringValue
            let expert_Name = responseExpert["name"]!.stringValue
            let expert_FName = responseExpert["f_name"]!.stringValue
            let profile_img = responseExpert["profile_pic"]!.stringValue
            
            NSUserDefaults.standardUserDefaults().setObject(auth_Token, forKey: "auth_token");
            NSUserDefaults.standardUserDefaults().setObject(expert_Id, forKey: "expert_id");
            NSUserDefaults.standardUserDefaults().setObject(expert_Name, forKey: "expert_Name");
            NSUserDefaults.standardUserDefaults().setObject(expert_FName, forKey: "expert_FName");
            NSUserDefaults.standardUserDefaults().setObject(profile_img, forKey: "profile_pic");
            NSUserDefaults.standardUserDefaults().synchronize();
            
            if let checkedUrl = NSURL(string: profile_img) {
                downloadImage(checkedUrl)
            }
        }
    }
    
    func apiFailureResponseWithURL(errorDesc: String, urlString: String) {
        SVProgressHUD.dismiss()
        print(errorDesc)
    }
}
