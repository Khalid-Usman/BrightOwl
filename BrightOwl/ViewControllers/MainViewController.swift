//
//  MainViewController.swift
//  BrightOwl
//
//  Created by Khalid Usman on 4/19/16.
//  Copyright © 2016 Khalid Usman. All rights reserved.
//

import UIKit
import Koloda
import pop
import Alamofire
import SwiftyJSON
import SVProgressHUD
import NVActivityIndicatorView

private var numberOfCards: UInt = 0
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class MainViewController: UIViewController, APIResponseDelegates {

    @IBOutlet weak var kolodaView : KolodaView!
    @IBOutlet weak var bottomBtnView : UIView!
    @IBOutlet weak var btnNotInterested : UIButton!
    @IBOutlet weak var btnInterested : UIButton!
    @IBOutlet weak var btnApply : UIButton!
    @IBOutlet weak var btnFavourite : UIButton!
    @IBOutlet weak var segmentCntrl : UISegmentedControl!
    
    var _imgView = UIImageView()
    
    var _jobsArray : NSMutableArray = []
    var _interestedJobsArray : NSMutableArray = []
    var _savedJobsArray : NSMutableArray = []
    var _appliedJobsArray : NSMutableArray = []
    var _jobsListArray : NSMutableArray = []
    var _interestedJobsListArray : NSMutableArray = []
    var _savedJobsListArray : NSMutableArray = []
    var _appliedJobsListArray : NSMutableArray = []
    var _jobsLocationsArray : NSMutableArray = []
    var _jobsFunctionalTitleArray : NSMutableArray = []
    var _jobsFieldsArray : NSMutableArray = []
    var _jobsLanguageArray : NSMutableArray = []
    
    var totalPages = 0
    var currentPage = 1
    var numberPerPage = 10
    
    var verticalDist : CGFloat = 2.0
    var startingDist : CGFloat = 10.0
    var progressbarHeight : CGFloat = 40
    var countryFont = UIFont(name: "Lato-Italic", size: 16)
    var titleFont = UIFont(name: "Lato-Bold", size: 16)
    var headlineRegularFont = UIFont(name: "Lato-Regular", size: 12)
    var headlineBoldFont = UIFont(name: "Lato-Bold", size: 12)
    var textAttributesTitle = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 16.0)!]
    var textAttributesBold = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 12.0)!]
    var textAttributesRegular = [NSFontAttributeName : UIFont(name: "Lato-Regular", size: 12.0)!]
    
    //MARK:- ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.animator = BackgroundKolodaAnimator(koloda: kolodaView)
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.navigationController?.navigationBar.hidden = false
        self.navigationItem.titleView = UIImageView(image:UIImage(named: "navCenterLogo"))
        self.segmentCntrl.hidden = true
        //downloadImg()
        
        self.addFontsAccordingDevice()
        showActivityIndicator()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UIBarButtonItems
    
    func clickOnButton(button: UIButton) {
        let introVC = self.storyboard?.instantiateViewControllerWithIdentifier("introVC")
        self.navigationController?.pushViewController(introVC!, animated: true)
    }
    
    @IBAction func btnSignOutPressed() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isNotFirstTime")
        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = mainStoryboard.instantiateViewControllerWithIdentifier("loginVC") as! LoginViewController
        appDelegate.window?.rootViewController = loginVC
        appDelegate.window?.makeKeyAndVisible()
    }
    
    @IBAction func btnRefreshPressed() {
        if (segmentCntrl.selectedSegmentIndex==0) {
            if (totalPages == 0 || currentPage<=totalPages) {
                getJobs()
            }
        }
        else if (segmentCntrl.selectedSegmentIndex==1) {
            getPreviousJobs("/interested")
        }
        else if (segmentCntrl.selectedSegmentIndex==2) {
            getPreviousJobs("/saved")
        }
        else {
            getPreviousJobs("/applied")
        }
    }
    
    // MARK:- Load Image
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        return image
    }
    
    // MARK:- Activity Indicator 
    
    func showActivityIndicator() {

        self.segmentCntrl.hidden = true
        let imagePath = fileInDocumentsDirectory("profile_Pic.png")
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        if (Utility.getDevice() == "iPad") {
            self.kolodaView.frame = CGRectMake(40, 88, screenSize.width-80, screenSize.height-216)
        }
        else if (Utility.getDevice() == "iPhone6") {
            self.kolodaView.frame = CGRectMake(20, 78, screenSize.width-40, screenSize.height-176)
        }
        else {
            self.kolodaView.frame = CGRectMake(10, 68, screenSize.width-20, screenSize.height-166)
        }
        
        //var activityFrame : CGRect = CGRectMake(10, 30, screenSize.width-20, screenSize.height-160)
        var activityFrame : CGRect = self.kolodaView.frame
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
            //activityFrame = CGRectMake(40, 60, screenSize.width-80, screenSize.height-320)
        }
        let activityIndicatorView = NVActivityIndicatorView(frame: activityFrame, color: UIColor(red: 96/255, green: 160/255, blue: 45/255, alpha: 1.0),type: .BallScaleMultiple)
        activityIndicatorView.padding = 20
        activityIndicatorView.startAnimation()
        if let loadedImage = loadImageFromPath(imagePath) {
            if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad) {
                self._imgView.frame = CGRectMake(0, 0, 160, 160)
            }
            else {
                self._imgView.frame = CGRectMake(0, 0, 100, 100)
            }
            self._imgView.contentMode = .ScaleAspectFit
            self._imgView.image = loadedImage
            self._imgView.layer.cornerRadius = self._imgView.frame.width/2
            self._imgView.clipsToBounds = true
        }
        self._imgView.center = CGPointMake(activityIndicatorView.frame.size.width  / 2,
                                           activityIndicatorView.frame.size.height / 2);
        activityIndicatorView.addSubview(self._imgView)
        
        self.view.addSubview(activityIndicatorView)
        if (totalPages == 0 || currentPage<=totalPages) {
            getJobs()
        }
    }
    
    //MARK:- API Functions
    
    func getJobs() {
        if (isConnectedToNetwork()==true) {
            do {
                let expertId : String = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                if expertId.isEmpty {
                    Utility.displayMessage("First Login Please")
                }
                else {
                    let numerPerPageStr = "\(numberPerPage)"
                    let currentPageStr = "\(currentPage)"
                    let urlString = "expert/" + expertId + "/jobs?" + "per_page=" + numerPerPageStr + "&current_page=" + currentPageStr
                    API.getRequest(urlString, jsonData:(nil), isLogin: true, delegate: self)
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    func getPreviousJobs(jobStr : String) {
        if (isConnectedToNetwork()==true) {
            do {
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                if (expertId.isEmpty == false) {
                    let urlString = "expert/jobs/" + expertId + jobStr
                    SVProgressHUD.showWithStatus("Loading...")
                    API.getRequest(urlString, jsonData:(nil), isLogin: true, delegate: self)
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    func sendInterestedJobs(isInterested: Bool, withIndex: Int) {
        if (isConnectedToNetwork()==true) {
            do {
                var interested = "1"
                if isInterested==false {
                    interested = "0"
                }
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                var projectId = ""
                if (self.segmentCntrl.selectedSegmentIndex==0 && self._jobsListArray.count>0) {
                    let tempDic = self._jobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex-withIndex))
                    projectId = tempDic["project_id"]! as! String
                }
                else if (self.segmentCntrl.selectedSegmentIndex==1 && self._interestedJobsListArray.count>0) {
                    let tempDic = self._interestedJobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex-withIndex))
                    projectId = tempDic["project_id"]! as! String
                }
                else if (self.segmentCntrl.selectedSegmentIndex==2 && self._savedJobsListArray.count>0) {
                    let tempDic = self._savedJobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex-withIndex))
                    projectId = tempDic["project_id"]! as! String
                }
                else {
                    let tempDic = self._appliedJobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex-withIndex))
                    projectId = tempDic["project_id"]! as! String
                }
                if (projectId.isEmpty==false && expertId.isEmpty == false) {
                    let parameters = ["expert_id": expertId, "project_id": projectId, "interested" : interested]
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
                    API.postRequest("project-interest", jsonData:jsonData, isLogin: true, delegate: self)
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    //MARK: IBActions
    
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
        self.sendInterestedJobs(false, withIndex: 1)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
        self.sendInterestedJobs(true, withIndex: 1)
    }
    
    @IBAction func refreshButtonTapped() {
        showActivityIndicator()
    }
    
    @IBAction func btnApplyJobPressed() {
        let applyJobVC = self.storyboard?.instantiateViewControllerWithIdentifier("applyJobVC") as! ApplyJobViewController
        if (self.segmentCntrl.selectedSegmentIndex==0 && self._jobsListArray.count>0) {
            let tempDic = self._jobsListArray.objectAtIndex(self.kolodaView.currentCardIndex)
            applyJobVC.newStr = tempDic["project_id"]! as! String
            applyJobVC.titleStr = tempDic["project_title"]! as! String
        }
        else if (self.segmentCntrl.selectedSegmentIndex==1 && self._interestedJobsListArray.count>0) {
            let tempDic = self._interestedJobsListArray.objectAtIndex(self.kolodaView.currentCardIndex)
            applyJobVC.newStr = tempDic["project_id"]! as! String
            applyJobVC.titleStr = tempDic["project_title"]! as! String
        }
        else if (self.segmentCntrl.selectedSegmentIndex==2 && self._savedJobsListArray.count>0) {
            let tempDic = self._savedJobsListArray.objectAtIndex(self.kolodaView.currentCardIndex)
            applyJobVC.newStr = tempDic["project_id"]! as! String
            applyJobVC.titleStr = tempDic["project_title"]! as! String
        }
        else {
            let tempDic = self._appliedJobsListArray.objectAtIndex(self.kolodaView.currentCardIndex)
            applyJobVC.newStr = tempDic["project_id"]! as! String
            applyJobVC.titleStr = tempDic["project_title"]! as! String
        }
        self.navigationController?.pushViewController(applyJobVC, animated: true)
    }
    
    @IBAction func bookmarkButtonTapped() {
        if (isConnectedToNetwork()==true) {
            do {
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                var projectId = ""
                if (self.segmentCntrl.selectedSegmentIndex==0 && self._jobsListArray.count>0) {
                    let tempDic = self._jobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex))
                    projectId = tempDic["project_id"]! as! String
                }
                else if (self.segmentCntrl.selectedSegmentIndex==1 && self._interestedJobsListArray.count>0) {
                    let tempDic = self._interestedJobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex))
                    projectId = tempDic["project_id"]! as! String
                }
                else if (self.segmentCntrl.selectedSegmentIndex==2 && self._savedJobsListArray.count>0) {
                    let tempDic = self._savedJobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex))
                    projectId = tempDic["project_id"]! as! String
                }
                else {
                    let tempDic = self._appliedJobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex))
                    projectId = tempDic["project_id"]! as! String
                }
                if (projectId.isEmpty==false && expertId.isEmpty == false) {
                    let parameters = ["expert_id": expertId, "project_id": projectId]
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
                    API.postRequest("expert/save/job", jsonData:jsonData, isLogin: true, delegate: self)
                    SVProgressHUD.showWithStatus("Loading...")
                }
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            Utility.displayMessage("Your device is not connected with internet!")
        }
    }
    
    @IBAction func interestedBtnNavTapped() {
        let saveJobVC = self.storyboard?.instantiateViewControllerWithIdentifier("saveJobVC")
        self.navigationController?.pushViewController(saveJobVC!, animated: true)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    @IBAction func segmentcontrolClicked() {
        if (segmentCntrl.selectedSegmentIndex==0) {
            if (totalPages == 0 || currentPage<totalPages) {
                self.kolodaView.hidden = true
                showActivityIndicator()
            }
            self.btnApply.userInteractionEnabled = true
            self.btnNotInterested.userInteractionEnabled = true
            self.btnInterested.userInteractionEnabled = true
            self.btnFavourite.userInteractionEnabled = true
        }
        else if (segmentCntrl.selectedSegmentIndex==1) {
            getPreviousJobs("/interested")
            self.btnApply.userInteractionEnabled = true
            self.btnNotInterested.userInteractionEnabled = true
            self.btnInterested.userInteractionEnabled = false
            self.btnFavourite.userInteractionEnabled = true
        }
        else if (segmentCntrl.selectedSegmentIndex==2) {
            getPreviousJobs("/saved")
            self.btnApply.userInteractionEnabled = true
            self.btnNotInterested.userInteractionEnabled = true
            self.btnInterested.userInteractionEnabled = true
            self.btnFavourite.userInteractionEnabled = false
        }
        else {
            getPreviousJobs("/applied")
            self.btnApply.userInteractionEnabled = false
            self.btnNotInterested.userInteractionEnabled = false
            self.btnInterested.userInteractionEnabled = false
            self.btnFavourite.userInteractionEnabled = false
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:- Adding Custom Views in Array
    
    func addFontsAccordingDevice() {
        
        if (Utility.getDevice() == "iPad") {
            headlineRegularFont = UIFont(name: "Lato-Regular", size: 20)
            headlineBoldFont = UIFont(name: "Lato-Bold", size: 20)
            countryFont = UIFont(name: "Lato-Italic", size: 26)
            titleFont = UIFont(name: "Lato-Bold", size: 26)
            textAttributesTitle = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 26)!]
            textAttributesBold = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 20)!]
            textAttributesRegular = [NSFontAttributeName : UIFont(name: "Lato-Regular", size: 20)!]
            verticalDist = 20
            startingDist = 20
            progressbarHeight = 60
        }
        else if (Utility.getDevice() == "iPhone6")  {
            countryFont = UIFont(name: "Lato-Italic", size: 22)
            titleFont = UIFont(name: "Lato-Bold", size: 22)
            textAttributesTitle = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 22)!]
            headlineRegularFont = UIFont(name: "Lato-Regular", size: 16)
            headlineBoldFont = UIFont(name: "Lato-Bold", size: 16)
            textAttributesBold = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 16.0)!]
            textAttributesRegular = [NSFontAttributeName : UIFont(name: "Lato-Regular", size: 16.0)!]
            verticalDist = 10
            startingDist = 20
            progressbarHeight = 40
        }
        else if (Utility.getDevice() == "iPhone5")  {
            countryFont = UIFont(name: "Lato-Italic", size: 16)
            titleFont = UIFont(name: "Lato-Bold", size: 16)
            textAttributesTitle = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 16)!]
            headlineRegularFont = UIFont(name: "Lato-Regular", size: 12)
            headlineBoldFont = UIFont(name: "Lato-Bold", size: 12)
            textAttributesBold = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 12.0)!]
            textAttributesRegular = [NSFontAttributeName : UIFont(name: "Lato-Regular", size: 12.0)!]
            verticalDist = 4
            startingDist = 15
            progressbarHeight = 40
        }
        else {
            //4S
        }
        self.segmentCntrl.setTitleTextAttributes(textAttributesRegular, forState: UIControlState.Normal)
        self.segmentCntrl.setTitleTextAttributes(textAttributesRegular, forState: UIControlState.Selected)
    }
    
    func addLabel(text: String , attributedText : NSAttributedString, isAttributed : Bool, customFrame : CGRect, customFont : UIFont, customColor : UIColor, textAligned : String) -> UILabel {
        let labelHeadline = UILabel(frame: customFrame)
        labelHeadline.numberOfLines = 0
        labelHeadline.lineBreakMode = NSLineBreakMode.ByWordWrapping
        if isAttributed==true {
            labelHeadline.attributedText = attributedText
        }
        else {
            labelHeadline.text = text
            labelHeadline.font = customFont
        }
        if textAligned=="0" {
            labelHeadline.textAlignment = NSTextAlignment.Left
        }
        else if textAligned=="1" {
            labelHeadline.textAlignment = NSTextAlignment.Center
        }
        else {
            labelHeadline.textAlignment = NSTextAlignment.Right
        }
        labelHeadline.textColor = customColor
        return labelHeadline
    }
    
    func addView(customFrame : CGRect, tempArr : NSMutableArray, customFont : UIFont) -> UIView {
        let viewContents : UIView = UIView()
        let textAttributes = [NSFontAttributeName : customFont]
        var k = 1
        var j = 1
        var totalWidth : Float = 0.0
        viewContents.frame = customFrame
        viewContents.backgroundColor = UIColor.clearColor()
        for (var i=0; i<tempArr.count; i++) {
            let tempStr = tempArr[i]
            let textRect = tempStr.boundingRectWithSize(CGSizeMake(1000, 20), options: .UsesLineFragmentOrigin, attributes: textAttributes, context: nil)
            if ((totalWidth) + Float(textRect.width) > Float(kolodaView.frame.width-20)) {
                totalWidth = 0.0
                k = k + 1
                j = 1
                break
            }
            let label:UILabel = UILabel(frame: CGRectMake(CGFloat(totalWidth+Float(j-1)*2), CGFloat(k-1)*textRect.height, textRect.width + 5, textRect.height))
            if i==tempArr.count-1 {
                label.text = (tempStr as? String)!
            }
            else {
                label.text = (tempStr as? String)! + ", "
            }
            label.font = customFont
            label.textColor = UIColor.darkGrayColor()
            label.layer.cornerRadius = 3
            label.textAlignment = .Center
            viewContents.addSubview(label)
            j = j + 1
            totalWidth = totalWidth + Float(textRect.width)
        }
        return viewContents
    }
    
    func addMatchingView(customFrame : CGRect, percentage : Float, customFont : UIFont) -> UIView {
        let viewMatch : UIView = UIView()
        viewMatch.frame = customFrame
        viewMatch.backgroundColor = UIColor.clearColor()
        for i in 0...4 {
            let label:UILabel = UILabel(frame: CGRectMake((CGFloat(i)*customFrame.width/5), 10, customFrame.width/5, customFrame.height-20))
            if i==0 {
                label.text = "Low"
                label.layer.backgroundColor = UIColor(red: 224/255, green: 255/255, blue: 150/255, alpha: 1.0).CGColor
            }
            else if i==1 {
                label.text = "Average"
                label.layer.backgroundColor = UIColor(red: 194/255, green: 255/255, blue: 124/255, alpha: 1.0).CGColor
            }
            else if i==2 {
                label.text = "Fair"
                label.layer.backgroundColor = UIColor(red: 164/255, green: 244/255, blue: 98/255, alpha: 1.0).CGColor
            }
            else if i==3 {
                label.text = "Good"
                label.layer.backgroundColor = UIColor(red: 137/255, green: 213/255, blue: 74/255, alpha: 1.0).CGColor
            }
            else {
                label.text = "Excellent"
                label.layer.backgroundColor = UIColor(red: 110/255, green: 182/255, blue: 51/255, alpha: 1.0).CGColor
            }
            label.font = customFont
            label.numberOfLines = 0
            label.textColor = UIColor.blackColor()
            label.textAlignment = .Center
            viewMatch.addSubview(label)
        }
        
        var startPoint : Int = 0
        if percentage<=20 {
            startPoint = 1
        }
        else if (percentage>20 && percentage<=40) {
            startPoint = 2
        }
        else if (percentage>40 && percentage<=60) {
            startPoint = 3
        }
        else if (percentage>60 && percentage<=80) {
            startPoint = 4
        }
        else {
            startPoint = 5
        }
        let start = 20*(CGFloat(startPoint-1)*customFrame.width)/100
        let end = 20*(CGFloat(startPoint)*customFrame.width)/100
        let diff = (end - start)/2 - 10
        let imgView:UIImageView = UIImageView(frame: CGRectMake(start+diff, 0, 20, 20))
        imgView.image = UIImage(named: "matchIcon")
        viewMatch.addSubview(imgView)
        
        return viewMatch
    }
    
    func addLineView(customFrame : CGRect) -> UIView {
        let viewLine : UIView = UIView()
        viewLine.frame = customFrame
        viewLine.backgroundColor = UIColor(red: 249/255, green: 244/255, blue: 223/255, alpha: 1.0)
        return viewLine
    }
    
    func addCustomViewsInArray(paramDict: Dictionary<String, AnyObject>? = nil, index: String) {
        
        let projectTitle = paramDict!["project_title"]!.description
        let attributedStringTitle = NSMutableAttributedString(string:projectTitle)
        let titleAttributes = [NSForegroundColorAttributeName: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0),NSFontAttributeName: titleFont!]
        attributedStringTitle.addAttributes(titleAttributes,  range: NSMakeRange(0,attributedStringTitle.length))
        let country  = " - \( paramDict!["country"]!.description)"
        let attributedString = NSMutableAttributedString(string:country)
        let thirdAttributes = [NSForegroundColorAttributeName: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0),NSFontAttributeName: countryFont!]
        attributedString.addAttributes(thirdAttributes,  range: NSMakeRange(0,attributedString.length))
        attributedStringTitle.appendAttributedString(attributedString);
        
        let dynamicView=UIView(frame: CGRectMake(10, 0, self.kolodaView.frame.width-20, self.kolodaView.bounds.height))
        dynamicView.layer.backgroundColor = UIColor.whiteColor().CGColor
        dynamicView.layer.cornerRadius=10
        dynamicView.layer.masksToBounds = true;
        
        let labelTitleString = projectTitle + country
        let textRectTitle = labelTitleString.boundingRectWithSize(CGSizeMake(kolodaView.frame.width-20, 1000), options: .UsesLineFragmentOrigin, attributes: textAttributesTitle, context: nil)
        dynamicView.addSubview(addLabel("", attributedText: attributedStringTitle, isAttributed: true, customFrame: CGRectMake(10, startingDist, kolodaView.frame.width-20, textRectTitle.height), customFont: titleFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "0"))
        
        let headlineString = paramDict!["project_headline"] as? String
        let textRectHeadline = headlineString!.boundingRectWithSize(CGSizeMake(kolodaView.frame.width-20, 50), options: .UsesLineFragmentOrigin, attributes: textAttributesRegular, context: nil)
        dynamicView.addSubview(addLabel(headlineString!, attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(10, startingDist+textRectTitle.height, kolodaView.frame.width-20, textRectHeadline.height), customFont: headlineRegularFont!, customColor: UIColor.darkGrayColor(), textAligned: "0"))
        
        let textRectProjectBold = "Project Type:".boundingRectWithSize(CGSizeMake(kolodaView.frame.width-20, 50), options: .UsesLineFragmentOrigin, attributes: textAttributesBold, context: nil)
        let textRectProject = "Project Type:".boundingRectWithSize(CGSizeMake(kolodaView.frame.width-20, 50), options: .UsesLineFragmentOrigin, attributes: textAttributesRegular, context: nil)
        dynamicView.addSubview(addLabel("Project Type:", attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(10, startingDist+textRectTitle.height+textRectHeadline.height+(verticalDist*1), kolodaView.frame.width-20, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "0"))
        
        let textRectProjectDetail = (paramDict!["project_types"] as? String)!.boundingRectWithSize(CGSizeMake(kolodaView.frame.width-20, 50), options: .UsesLineFragmentOrigin, attributes: textAttributesRegular, context: nil)
        dynamicView.addSubview(addLabel((paramDict!["project_types"] as? String)!, attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(10,startingDist+textRectTitle.height+textRectHeadline.height+textRectProjectBold.height+(verticalDist*1), kolodaView.frame.width-20, textRectProjectDetail.height), customFont: headlineRegularFont!, customColor: UIColor.darkGrayColor(), textAligned: "0"))
        
        var _localHeight : CGFloat = 0.0
        var _localDist : CGFloat = 2.0
        let _aboveLabelsHeight : CGFloat = startingDist+textRectTitle.height+textRectHeadline.height+textRectProjectBold.height+textRectProjectDetail.height
        
        dynamicView.addSubview(addLineView(CGRectMake(0, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist)-verticalDist/2, kolodaView.frame.width, 1)))
        
        let tempLocArr = paramDict!["location"] as! NSMutableArray
        if tempLocArr.count>0 {
            dynamicView.addSubview(addLabel(("Location:"), attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(10,_aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-20, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "0"))
            dynamicView.addSubview(addView(CGRectMake(10, _aboveLabelsHeight+textRectProjectBold.height+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-20,textRectProject.height), tempArr:  tempLocArr, customFont: headlineRegularFont!))
            _localHeight = _localHeight + textRectProject.height + textRectProjectBold.height
            _localDist = _localDist + 1
            
            dynamicView.addSubview(addLineView(CGRectMake(0, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist)-verticalDist/2, kolodaView.frame.width, 1)))
        }
        let tempFuncTitleArr = paramDict!["ftitles"] as! NSMutableArray
        if tempFuncTitleArr.count>0 {
            dynamicView.addSubview(addLabel(("Functional Title:"), attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(10, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-20, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "0"))
            dynamicView.addSubview(addView(CGRectMake(10, _aboveLabelsHeight+textRectProjectBold.height+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-20,textRectProject.height), tempArr:  tempFuncTitleArr, customFont: headlineRegularFont!))
            _localHeight = _localHeight + textRectProject.height + textRectProjectBold.height
            _localDist = _localDist + 1
            
            dynamicView.addSubview(addLineView(CGRectMake(0, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist)-verticalDist/2, kolodaView.frame.width, 1)))
        }
        let tempFieldStudyArr = paramDict!["studyfields"] as! NSMutableArray
        if tempFieldStudyArr.count>0 {
            dynamicView.addSubview(addLabel(("Field of Study:"), attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(10, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-20, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "0"))
            dynamicView.addSubview(addView(CGRectMake(10, _aboveLabelsHeight+textRectProjectBold.height+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-20,textRectProject.height), tempArr:  tempFieldStudyArr, customFont: headlineRegularFont!))
            _localHeight = _localHeight + textRectProject.height + textRectProjectBold.height
            _localDist = _localDist + 1
            
            dynamicView.addSubview(addLineView(CGRectMake(0, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist)-verticalDist/2, kolodaView.frame.width, 1)))
        }
        let tempLangArr = paramDict!["languages"] as! NSMutableArray
        if tempLangArr.count>0 {
            dynamicView.addSubview(addLabel(("Language:"), attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(10, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-20, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "0"))
            dynamicView.addSubview(addView(CGRectMake(10, _aboveLabelsHeight+textRectProjectBold.height+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-20, textRectProject.height), tempArr:  tempLangArr, customFont: headlineRegularFont!))
            _localHeight = _localHeight + textRectProjectBold.height + textRectProject.height
            _localDist = _localDist + 1
            
            dynamicView.addSubview(addLineView(CGRectMake(0, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist)-verticalDist/2, kolodaView.frame.width, 1)))
        }
        
        dynamicView.addSubview(addLabel("Project FTE", attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(0, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width/3, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "1"))
        
        dynamicView.addSubview(addLineView(CGRectMake(kolodaView.frame.width/3, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist)-verticalDist/2, 1, textRectProjectBold.height+textRectProject.height+verticalDist)))
        
        dynamicView.addSubview(addLabel("Min. Experience", attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(kolodaView.frame.width/3, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width/3, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "1"))
        
        dynamicView.addSubview(addLineView(CGRectMake(2*(kolodaView.frame.width/3), _aboveLabelsHeight+_localHeight+(verticalDist*_localDist)-verticalDist/2, 1, textRectProjectBold.height+textRectProject.height+verticalDist)))
        
        dynamicView.addSubview(addLabel("Start Date", attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(2*(kolodaView.frame.width/3), _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width/3, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "1"))
        
        _localHeight = _localHeight + textRectProjectBold.height
        //_localDist = _localDist + 1
        
        let fteStr = paramDict!["project_fte"] as? String
        dynamicView.addSubview(addLabel((fteStr! + "%"), attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(0, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width/3, textRectProject.height), customFont: headlineRegularFont!, customColor: UIColor.darkGrayColor(), textAligned: "1"))
        
        let expStr = paramDict!["minimum_experience"] as? String
        dynamicView.addSubview(addLabel((expStr!), attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(kolodaView.frame.width/3, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width/3, textRectProject.height), customFont: headlineRegularFont!, customColor: UIColor.darkGrayColor(), textAligned: "1"))
        
        var sdateStr = paramDict!["start_date"] as? String
        if (sdateStr == nil || sdateStr?.isEmpty == true) {
            sdateStr = "ASAP"
        }
        dynamicView.addSubview(addLabel((sdateStr!), attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(2*(kolodaView.frame.width/3), _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width/3, textRectProject.height), customFont: headlineRegularFont!, customColor: UIColor.darkGrayColor(), textAligned: "1"))
        
        _localHeight = _localHeight + textRectProject.height
        _localDist = _localDist + 1
        
        dynamicView.addSubview(addLineView(CGRectMake(0, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist)-verticalDist/2, kolodaView.frame.width, 1)))

        dynamicView.addSubview(addLabel(("Profile Match:"), attributedText: attributedStringTitle, isAttributed: false, customFrame: CGRectMake(10, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width/3, textRectProjectBold.height), customFont: headlineBoldFont!, customColor: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0), textAligned: "0"))
        
        var progressVal = paramDict!["profile_match_result"] as? String
        if (progressVal == nil || progressVal?.isEmpty == true) {
            progressVal = "0"
        }
        _localHeight = _localHeight + textRectProjectBold.height
        dynamicView.addSubview(addMatchingView(CGRectMake(5, _aboveLabelsHeight+_localHeight+(verticalDist*_localDist), kolodaView.frame.width-10, progressbarHeight), percentage: Float(progressVal!)!, customFont: headlineRegularFont!))
        
        if (index=="0") {
            self._jobsArray.addObject(dynamicView)
        }
        else if (index=="1") {
            self._interestedJobsArray.addObject(dynamicView)
        }
        else if (index=="2") {
            self._savedJobsArray.addObject(dynamicView)
        }
        else {
            self._appliedJobsArray.addObject(dynamicView)
        }
    }
    
    //MARK:- API Response Delegates
    
    func apiSuccessResponseWithURL(json: JSON, urlString : String) {
         SVProgressHUD.dismiss()
        if urlString.containsString("project-interest") {
            // Interested or not-Interested
            let statusString = json["status"].stringValue
//            if (self.segmentCntrl.selectedSegmentIndex==0 && self._jobsListArray.count>0) {
//                let tempDic = self._jobsListArray.objectAtIndex(Int(kolodaView.currentCardIndex-1))
//                self._jobsListArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex-1))
//                self._jobsArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex-1))
//            }
//            else if (self.segmentCntrl.selectedSegmentIndex==1 && self._interestedJobsListArray.count>0) {
//                self._interestedJobsListArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex-1))
//                self._interestedJobsArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex-1))
//            }
//            else if (self.segmentCntrl.selectedSegmentIndex==2 && self._savedJobsListArray.count>0) {
//                self._savedJobsListArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex-1))
//                self._savedJobsArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex-1))
//            }
//            else {
//                // Nothing
//            }
//            self.kolodaView.resetCurrentCardIndex()
//            self.kolodaView.reloadData()
            if (statusString == "200") {
                return;
            }
        }
        else if urlString.containsString("expert/save/job") {
            let statusString = json["status"].stringValue
//            if (self.segmentCntrl.selectedSegmentIndex==0 && self._jobsListArray.count>0) {
//                self._jobsListArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex))
//                self._jobsArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex))
//            }
//            else if (self.segmentCntrl.selectedSegmentIndex==1 && self._interestedJobsListArray.count>0) {
//                self._interestedJobsListArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex))
//                self._interestedJobsArray.removeObjectAtIndex(Int(kolodaView.currentCardIndex))
//            }
//            else {
//                // Nothing
//            }
//            self.kolodaView.resetCurrentCardIndex()
//            self.kolodaView.reloadData()
            if (statusString == "200") {
                return;
            }
        }
        else {
            let statusString = json["status"].stringValue
            if (statusString == "350") {
                Utility.displayMessage("No Job Found!");
                return;
            }
            let responseUser: Dictionary<String, JSON> = json["response"].dictionaryValue
            if responseUser.count>0 {
                let applications: Array<JSON> = responseUser["projects"]!.arrayValue
                if (urlString.containsString("interested")) {
                    self._interestedJobsArray.removeAllObjects()
                    self._interestedJobsListArray.removeAllObjects()
                }
                else if (urlString.containsString("saved")) {
                    self._savedJobsArray.removeAllObjects()
                    self._savedJobsListArray.removeAllObjects()
                }
                else if (urlString.containsString("applied")) {
                    self._appliedJobsArray.removeAllObjects()
                    self._appliedJobsListArray.removeAllObjects()
                }
                else {
                    self._jobsArray.removeAllObjects()
                    self._jobsListArray.removeAllObjects()
                }

                for project in applications {
                    var tempDic = [String: AnyObject]()
                    
                    tempDic["project_id"] = project["project_id"].stringValue
                    tempDic["project_title"] = project["project_title"].stringValue
                    tempDic["project_headline"] = project["project_headline"].stringValue
                    tempDic["country"] = project["country"].stringValue
                    tempDic["project_type_id"] = project["project_type_id"].stringValue
                    tempDic["minimum_experience"] = project["minimum_experience"].stringValue
                    tempDic["start_date"] = project["start_date"].stringValue
                    tempDic["end_date"] = project["end_date"].stringValue
                    tempDic["profile_match_result"] = project["profile_match_result"].stringValue
                    tempDic["project_fte"] = project["project_fte"].stringValue
                    tempDic["project_types"] = project["project_types"].stringValue
                    tempDic["project_current_stage_id"] = project["project_current_stage_id"].stringValue
                    tempDic["project_current_stage_name"] = project["project_current_stage_name"].stringValue
                    tempDic["alreadyApplied"] = project["applied"].stringValue
                    
                    let locations: Array<JSON> = project["regions"].arrayValue
                    let _tempLocationsArray : NSMutableArray = []
                    for location in locations {
                        [_tempLocationsArray .addObject(location["project_location"].stringValue)];
                    }
                    tempDic["location"] = _tempLocationsArray
                    
                    let funcTitles: Array<JSON> = project["ftitles"].arrayValue
                    let _tempfuncTitlesArray : NSMutableArray = []
                    for funcTitle in funcTitles {
                        [_tempfuncTitlesArray .addObject(funcTitle["project_ftitle"].stringValue)];
                    }
                    tempDic["ftitles"] = _tempfuncTitlesArray
                    
                    let fields: Array<JSON> = project["studyfields"].arrayValue
                    let _tempFieldsArray : NSMutableArray = []
                    for field in fields {
                        [_tempFieldsArray .addObject(field["title"].stringValue)];
                    }
                    tempDic["studyfields"] = _tempFieldsArray
                    
                    let languages: Array<JSON> = project["languages"].arrayValue
                    let _tempLanguagesArray : NSMutableArray = []
                    for language in languages {
                        [_tempLanguagesArray .addObject(language["lang_name"].stringValue)];
                    }
                    tempDic["languages"] = _tempLanguagesArray
                    
                    if (urlString.containsString("interested")) {
                        [self._interestedJobsListArray .addObject(tempDic)]
                    }
                    else if (urlString.containsString("saved")) {
                        [self._savedJobsListArray .addObject(tempDic)]
                    }
                    else if (urlString.containsString("applied")) {
                        [self._appliedJobsListArray .addObject(tempDic)]
                    }
                    else {
                        [self._jobsListArray .addObject(tempDic)]
                    }
                }
                if (urlString.containsString("interested")) {
                    for dic in self._interestedJobsListArray {
                        [addCustomViewsInArray(dic as? Dictionary<String, AnyObject>, index: "1")]
                    }
                }
                else if (urlString.containsString("saved")) {
                    for dic in self._savedJobsListArray {
                        [addCustomViewsInArray(dic as? Dictionary<String, AnyObject>, index: "2")]
                    }
                }
                else if (urlString.containsString("applied")) {
                    for dic in self._appliedJobsListArray {
                        [addCustomViewsInArray(dic as? Dictionary<String, AnyObject>, index: "3")]
                    }
                }
                else {
                    for dic in self._jobsListArray {
                        [addCustomViewsInArray(dic as? Dictionary<String, AnyObject>, index: "0")]
                    }
                }
                let theSubviews : Array<UIView> = self.view.subviews as Array<UIView>
                for view in theSubviews {
                    if view.isKindOfClass(NVActivityIndicatorView) {
                        view.removeFromSuperview()
                    }
                }
                self.kolodaView.resetCurrentCardIndex()
                self.kolodaView.reloadData()
                self.segmentCntrl.hidden = false
                self.kolodaView.hidden = false
            }
        }
    }
    
    func apiFailureResponseWithURL(errorDesc: String, urlString: String) {
        SVProgressHUD.dismiss()
        print("Failed \(errorDesc)")
    }
}

//MARK: KolodaViewDelegate
extension MainViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        currentPage = currentPage + 1
        if ((totalPages == 0 || currentPage<totalPages) && self.segmentCntrl.selectedSegmentIndex==0) {
            self.kolodaView.resetCurrentCardIndex()
            self.kolodaView.reloadData()
            self.kolodaView.hidden = true
            showActivityIndicator()
        }
        else {
            Utility.displayMessage("No More projects to display")
        }
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        if (self.segmentCntrl.selectedSegmentIndex==0) {
            let jobDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("jobDetailVC") as! JobDetailViewController
            let tempDic = self._jobsListArray.objectAtIndex(Int(index))
            jobDetailVC.projectId = tempDic["project_id"]! as! String
            jobDetailVC.projectStage = tempDic["project_current_stage_name"]! as! String
            self.navigationController?.pushViewController(jobDetailVC, animated: true)
        }
        else if (self.segmentCntrl.selectedSegmentIndex==1) {
            let jobDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("jobDetailVC") as! JobDetailViewController
            let tempDic = self._interestedJobsListArray.objectAtIndex(Int(index))
            jobDetailVC.projectId = tempDic["project_id"]! as! String
            jobDetailVC.projectStage = tempDic["project_current_stage_name"]! as! String
            self.navigationController?.pushViewController(jobDetailVC, animated: true)
        }
        else if (self.segmentCntrl.selectedSegmentIndex==2) {
            let jobDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("jobDetailVC") as! JobDetailViewController
            let tempDic = self._savedJobsListArray.objectAtIndex(Int(index))
            jobDetailVC.projectId = tempDic["project_id"]! as! String
            jobDetailVC.projectStage = tempDic["project_current_stage_name"]! as! String
            self.navigationController?.pushViewController(jobDetailVC, animated: true)
        }
        else {
            let jobDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("jobDetailVC") as! JobDetailViewController
            let tempDic = self._appliedJobsListArray.objectAtIndex(Int(index))
            jobDetailVC.projectId = tempDic["project_id"]! as! String
            jobDetailVC.projectStage = tempDic["project_current_stage_name"]! as! String
            self.navigationController?.pushViewController(jobDetailVC, animated: true)
        }
    }
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation.springBounciness = frameAnimationSpringBounciness
        animation.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}

//MARK: KolodaViewDataSource
extension MainViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda:KolodaView) -> UInt {
        if (self.segmentCntrl.selectedSegmentIndex==0) {
            return UInt(self._jobsArray.count)
        }
        else if (self.segmentCntrl.selectedSegmentIndex==1) {
            return UInt(self._interestedJobsArray.count)
        }
        else if (self.segmentCntrl.selectedSegmentIndex==2) {
            return UInt(self._savedJobsArray.count)
        }
        else {
            return UInt(self._appliedJobsArray.count)
        }
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        if (self.segmentCntrl.selectedSegmentIndex==0) {
            return self._jobsArray[Int(index)] as! UIView
        }
        else if (self.segmentCntrl.selectedSegmentIndex==1) {
            return self._interestedJobsArray[Int(index)] as! UIView
        }
        else if (self.segmentCntrl.selectedSegmentIndex==2) {
            return self._savedJobsArray[Int(index)] as! UIView
        }
        else {
            return self._appliedJobsArray[Int(index)] as! UIView
        }
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView",
                                                  owner: self, options: nil)[0] as? OverlayView
    }
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        if (direction==SwipeResultDirection.Right) {
            self.sendInterestedJobs(true, withIndex: 1)
        }
        else {
            self.sendInterestedJobs(false, withIndex: 1)
        }
    }
}
