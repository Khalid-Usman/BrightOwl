//
//  JobDetailViewController.swift
//  BrightOwl
//
//  Created by Khalid Usman on 4/30/16.
//  Copyright © 2016 Khalid Usman. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD
import ABSteppedProgressBar

extension UIView {
    func rotate(toValue: CGFloat, duration: CFTimeInterval = 0.2, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = duration
        rotateAnimation.removedOnCompletion = false
        rotateAnimation.fillMode = kCAFillModeForwards
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}

class JobDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , APIResponseDelegates {

    @IBOutlet weak var _jobDetailTableView: UITableView!
    @IBOutlet weak var _headerTitleLabel: UILabel!
    @IBOutlet weak var _headerHeadlineLabel: UILabel!
    @IBOutlet weak var _headerProjTypeLabel: UILabel!
    @IBOutlet weak var _headerProjTypeText: UILabel!
    @IBOutlet weak var _headerFuncTitleLabel: UILabel!
    @IBOutlet weak var _headerFuncTitleText: UILabel!
    @IBOutlet weak var _headerLocLabel: UILabel!
    @IBOutlet weak var _headerLocText: UILabel!
    @IBOutlet weak var _headerFteLabel: UILabel!
    @IBOutlet weak var _headerFteText: UILabel!
    @IBOutlet weak var _headerExpLabel: UILabel!
    @IBOutlet weak var _headerExpText: UILabel!
    @IBOutlet weak var _headerStartDateLabel: UILabel!
    @IBOutlet weak var _headerStartDateText: UILabel!
    @IBOutlet weak var _headerProfileMatchLabel: UILabel!
    @IBOutlet weak var _headerProfileMatchView: UIView!
    @IBOutlet weak var _headerCurrentStageLabel: UILabel!
    @IBOutlet weak var _headerCurrentStageText: UILabel!
//    @IBOutlet weak var _headerCurrentStageBar: ABSteppedProgressBar!
    
    
    struct Section {
        var name: String!
        var items: [String]!
        var details: [String]!
        var collapsed: Bool!
        
        init(name: String, items: [String], details: [String], collapsed: Bool = false) {
            self.name = name
            self.items = items
            self.details = details
            self.collapsed = collapsed
        }
    }
    var sections = [Section]()
    
    var _globalHeight = 0
    var projectId : String = ""
    var projectStage : String = ""
    
    var _summary : String = ""
    var _desiredSkills : String = ""
    var _offersDetail : String = ""
    var _compentencyTitles : String = ""
    var _compentencyDetails : String = ""
    
    var countryFont = UIFont(name: "Lato-Italic", size: 16)
    var titleFont = UIFont(name: "Lato-Bold", size: 16)
    var headlineRegularFont = UIFont(name: "Lato-Regular", size: 12)
    var headlineBoldFont = UIFont(name: "Lato-Bold", size: 12)
    var textAttributesTitle = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 16.0)!]
    var textAttributesBold = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 12.0)!]
    var textAttributesRegular = [NSFontAttributeName : UIFont(name: "Lato-Regular", size: 12.0)!]
    var customHeight = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.navigationItem.titleView = UIImageView(image:UIImage(named: "navCenterLogo"))
        
        addFontsAccordingDevice()
        getJobDetail()
        
        _jobDetailTableView.estimatedRowHeight = UITableViewAutomaticDimension
        _jobDetailTableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Add Custom Fonts
    
    func addFontsAccordingDevice() {
        
        if (Utility.getDevice() == "iPad") {
            headlineRegularFont = UIFont(name: "Lato-Regular", size: 20)
            headlineBoldFont = UIFont(name: "Lato-Bold", size: 20)
            countryFont = UIFont(name: "Lato-Italic", size: 26)
            titleFont = UIFont(name: "Lato-Bold", size: 26)
            textAttributesTitle = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 26)!]
            textAttributesBold = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 20)!]
            textAttributesRegular = [NSFontAttributeName : UIFont(name: "Lato-Regular", size: 20)!]
        }
        else if (Utility.getDevice() == "iPhone6")  {
            countryFont = UIFont(name: "Lato-Italic", size: 22)
            titleFont = UIFont(name: "Lato-Bold", size: 22)
            textAttributesTitle = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 22)!]
            headlineRegularFont = UIFont(name: "Lato-Regular", size: 14)
            headlineBoldFont = UIFont(name: "Lato-Bold", size: 14)
            textAttributesBold = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 14.0)!]
            textAttributesRegular = [NSFontAttributeName : UIFont(name: "Lato-Regular", size: 14.0)!]
        }
        else if (Utility.getDevice() == "iPhone5")  {
            countryFont = UIFont(name: "Lato-Italic", size: 16)
            titleFont = UIFont(name: "Lato-Bold", size: 16)
            textAttributesTitle = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 16)!]
            headlineRegularFont = UIFont(name: "Lato-Regular", size: 13)
            headlineBoldFont = UIFont(name: "Lato-Bold", size: 13)
            textAttributesBold = [NSFontAttributeName : UIFont(name: "Lato-Bold", size: 13.0)!]
            textAttributesRegular = [NSFontAttributeName : UIFont(name: "Lato-Regular", size: 13.0)!]
        }
        else {
            //print("4S")

        }
    }
    
    // MARK:- IBActions
    
    func clickOnButton(button: UIButton) {
        let introVC = self.storyboard?.instantiateViewControllerWithIdentifier("introVC")
        self.navigationController?.pushViewController(introVC!, animated: true)
    }
    
    @IBAction func btnApplyJobPressed() {
        let applyJobVC = self.storyboard?.instantiateViewControllerWithIdentifier("applyJobVC") as! ApplyJobViewController
        applyJobVC.newStr = self.projectId
        applyJobVC.titleStr = self._headerTitleLabel.text!
        self.navigationController?.pushViewController(applyJobVC, animated: true)
    }
    
    @IBAction func btnInterestedJobPressed() {
        self.sendInterestedJobs(true)
    }
    
    @IBAction func btnNotInterestedJobPressed() {
        self.sendInterestedJobs(false)
    }
    
    @IBAction func btnSaveJobPressed() {
        if (isConnectedToNetwork()==true) {
            do {
                
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                let projectId = self.projectId
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
    
    //MARK:- Get Jobs
    
    func getJobDetail() {
        if (isConnectedToNetwork()==true) {
            do {
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                if (self.projectId.isEmpty==false && expertId.isEmpty == false) {
                    let parameters = ["expert_id": expertId, "project_id": self.projectId]
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
                    API.postRequest("project-detail", jsonData:jsonData, isLogin: true, delegate: self)
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
    
    func sendInterestedJobs(isInterested: Bool) {
        if (isConnectedToNetwork()==true) {
            do {
                var interested = "1"
                if isInterested==false {
                    interested = "0"
                }
                let expertId = NSUserDefaults.standardUserDefaults().valueForKey("expert_id") as! String
                if (self.projectId.isEmpty==false && expertId.isEmpty == false) {
                    let parameters = ["expert_id": expertId, "project_id": self.projectId, "interested" : interested]
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
                    API.postRequest("project-interest", jsonData:jsonData, isLogin: true, delegate: self)
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
    
    //MARK:- UITabelView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (sections[section].name == "Competency") {
            let tempStr = sections[section].items[0] as String
            let tempArr = tempStr.componentsSeparatedByString("*")
            return (sections[section].collapsed!) ? 0 : tempArr.count-1
        }
        return (sections[section].collapsed!) ? 0 : sections[section].items.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (sections[section].name == ".") {
            return nil
        }
        let header = tableView.dequeueReusableCellWithIdentifier("header") as! CollapsibleTableViewHeader
        header.toggleButton.tag = section
        header.titleLabel.text = sections[section].name
        header.titleLabel.font = headlineBoldFont
        if sections[section].collapsed == false {
            header.toggleButton.setImage(UIImage(named: "minus"), forState: UIControlState.Normal)
        }
        else {
            header.toggleButton.setImage(UIImage(named: "plus"), forState: UIControlState.Normal)
        }
        //header.toggleButton.rotate(sections[section].collapsed! ? 0.0 : CGFloat(M_PI))
        header.toggleButton.addTarget(self, action: #selector(toggleCollapse), forControlEvents: .TouchUpInside)
        return header.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (sections[section].name == ".") {
            return 1
        }
        else {
            return 43
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (sections[indexPath.section].name == "." || sections[indexPath.section].name == "Competency") {
            let cell = tableView.dequeueReusableCellWithIdentifier("profileSection", forIndexPath: indexPath)
            cell.textLabel?.font = headlineBoldFont
            cell.detailTextLabel?.font = headlineRegularFont
            let tempItemStr = sections[indexPath.section].items[0] as String
            let tempItemArr = tempItemStr.componentsSeparatedByString("*")
            let tempDetailStr = sections[indexPath.section].details[0] as String
            let tempDetailArr = tempDetailStr.componentsSeparatedByString("*")
            cell.textLabel?.text = tempItemArr[indexPath.row]
            cell.detailTextLabel?.text = tempDetailArr[indexPath.row]
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("textCell", forIndexPath: indexPath)
            cell.textLabel?.font = headlineRegularFont
            cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func toggleCollapse(sender: UIButton) {
        let section = sender.tag
        let collapsed = sections[section].collapsed
        sections[section].collapsed = !collapsed
        _jobDetailTableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .Automatic)
    }
    
    //MARK:- Update Views
    
    func addMatchingView(percentage : Float, customFont : UIFont) {
        for i in 0...4 {
            let label:UILabel = UILabel(frame: CGRectMake((CGFloat(i)*_headerProfileMatchView.frame.width/5), 10, _headerProfileMatchView.frame.width/5, _headerProfileMatchView.frame.height-20))
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
            _headerProfileMatchView.addSubview(label)
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
        let start = 20*(CGFloat(startPoint-1)*_headerProfileMatchView.frame.width)/100
        let end = 20*(CGFloat(startPoint)*_headerProfileMatchView.frame.width)/100
        let diff = (end - start)/2 - 10
        let imgView:UIImageView = UIImageView(frame: CGRectMake(start+diff, 0, 20, 20))
        imgView.image = UIImage(named: "matchIcon")
        _headerProfileMatchView.addSubview(imgView)
    }
    
    func updateView(projectTitle: String, countryName: String, projectHeadline: String, projectFte: String, projectExp: String, projectSDate: String, projectMatch: String) {
        
        let attributedStringTitle = NSMutableAttributedString(string:projectTitle + " ")
        let titleAttributes = [NSForegroundColorAttributeName: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0),NSFontAttributeName: titleFont!]
        attributedStringTitle.addAttributes(titleAttributes,  range: NSMakeRange(0,attributedStringTitle.length))
        let attributedString = NSMutableAttributedString(string:countryName)
        let thirdAttributes = [NSForegroundColorAttributeName: UIColor(red: 39/255, green: 48/255, blue: 77/255, alpha: 1.0),NSFontAttributeName: countryFont!]
        attributedString.addAttributes(thirdAttributes,  range: NSMakeRange(0,attributedString.length))
        attributedStringTitle.appendAttributedString(attributedString);
        
        self._headerTitleLabel.attributedText = attributedStringTitle
        self._headerHeadlineLabel.font = headlineRegularFont
        self._headerHeadlineLabel.text = projectHeadline
        
        self._headerFteLabel.font = headlineBoldFont
        self._headerFteText.font = headlineRegularFont
        self._headerFteLabel.text = "Project FTE"
        self._headerFteText.text = projectFte + "%"
        self._headerExpLabel.font = headlineBoldFont
        self._headerExpText.font = headlineRegularFont
        self._headerExpLabel.text = "Min. Experience"
        self._headerExpText.text = projectExp
        self._headerStartDateLabel.font = headlineBoldFont
        self._headerStartDateText.font = headlineRegularFont
        self._headerStartDateLabel.text = "Start Date"
        self._headerStartDateText.text = projectSDate
        
        self._headerProfileMatchLabel.font = headlineBoldFont
        self._headerProfileMatchLabel.text = "Profile Match"
        let projMatch = Float(projectMatch)
        self.addMatchingView(projMatch!, customFont: headlineRegularFont!)
    }

    //MARK:- API Response Delegates
    
    func apiSuccessResponseWithURL(json: JSON, urlString : String) {
        SVProgressHUD.dismiss()
        if urlString.containsString("project-interest") {
            // Interested or not-Interested
            let statusString = json["status"].stringValue
            if (statusString == "200") {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                Utility.displayMessage("Failed!");
            }
        }
        else if urlString.containsString("expert/save/job") {
            let statusString = json["status"].stringValue
            if (statusString == "200") {
                return
            }
            else {
                Utility.displayMessage("Failed!");
            }
        }
        else {
            
            let statusString = json["status"].stringValue
            if (statusString != "200") {
                Utility.displayMessage("No Job Found!");
                return;
            }
            let responseUser: Dictionary<String, JSON> = json["response"].dictionaryValue
            let project: Dictionary<String, JSON> = responseUser["projects"]!.dictionaryValue
            
            let projectTitle = project["project_title"]!.stringValue
            let country  = project["regions"]![0]["country"].stringValue
            let projectHeadline = project["project_headline"]!.stringValue
            let projectFte = project["project_fte"]!.stringValue
            let projectExp = project["total_experience"]!.stringValue
            var projectSDate = project["start_date"]!.stringValue
            if (projectSDate.isEmpty == true) {
                projectSDate = "ASAP"
            }
            var projectMatch = project["matchPercent"]!.stringValue
            if projectMatch.isEmpty {
                projectMatch = "0"
            }
            [updateView(projectTitle, countryName: country, projectHeadline: projectHeadline, projectFte: projectFte, projectExp: projectExp, projectSDate: projectSDate, projectMatch: projectMatch)]
            
            _headerCurrentStageLabel.font = headlineBoldFont
            _headerCurrentStageLabel.text = "Project is currently here"
            _headerCurrentStageText.font = headlineRegularFont
            if (project["project_current_stage_name"] != nil) {
                _headerCurrentStageText.text = project["project_current_stage_name"]!.stringValue
            }
            else {
                _headerCurrentStageText.text = self.projectStage
            }
            
//            _headerCurrentStageBar.delegate = self
//            _headerCurrentStageBar.currentIndex = 4
            
            _summary = ""
            _compentencyTitles = ""
            _compentencyDetails = ""
            _desiredSkills = ""
            _offersDetail = ""
            
            if (project["type"]!.arrayValue.count)>0 {
                var typesStr : String = ""
                let types: Array<JSON> = project["type"]!.arrayValue
                for type in types {
                    typesStr = typesStr + (type["project_type_name"].stringValue) + ","
                }
                self._headerProjTypeLabel.font = headlineBoldFont
                self._headerProjTypeText.font = headlineRegularFont
                self._headerProjTypeLabel.text = "Project Types"
                self._headerProjTypeText.text = String(typesStr.characters.dropLast())
            }
            if (project["ftitles"]!.arrayValue.count)>0 {
                var funcTitlesStr : String = ""
                let ftitles: Array<JSON> = project["ftitles"]!.arrayValue
                for ftitle in ftitles {
                    funcTitlesStr = funcTitlesStr + (ftitle["project_ftitle"].stringValue) + ","
                }
                self._headerFuncTitleLabel.font = headlineBoldFont
                self._headerFuncTitleText.font = headlineRegularFont
                self._headerFuncTitleLabel.text = "Functional Titles"
                self._headerFuncTitleText.text = String(funcTitlesStr.characters.dropLast())
            }
            if (project["regions"]!.arrayValue.count)>0 {
                var locStr : String = ""
                let regions: Array<JSON> = project["regions"]!.arrayValue
                for region in regions {
                    locStr = locStr + (region["project_location"].stringValue) + ","
                }
                self._headerLocLabel.font = headlineBoldFont
                self._headerLocText.font = headlineRegularFont
                self._headerLocLabel.text = "Locations"
                self._headerLocText.text = String(locStr.characters.dropLast())
            }
            
            if (project["project_description"]!.stringValue.isEmpty==false) {
                _summary = project["project_description"]!.stringValue
                _summary = _summary.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                sections.append(Section(name: "Description", items:[_summary], details: [""] , collapsed: false))
            }
            if (project["personality"]!.arrayValue.count)>0 {
                var personalityStr : String = ""
                let personalities: Array<JSON> = project["personality"]!.arrayValue
                for personality in personalities {
                    personalityStr = personalityStr + (personality["p_title"].stringValue) + ","
                }
                _compentencyTitles = _compentencyTitles + "Personality" + "*"
                _compentencyDetails = _compentencyDetails + String(personalityStr.characters.dropLast()) + "*"
            }
            if (project["knowledge"]!.arrayValue.count)>0 {
                var knowledgeStr : String = ""
                let knowledges: Array<JSON> = project["knowledge"]!.arrayValue
                for knowledge in knowledges {
                    knowledgeStr = knowledgeStr + (knowledge["know_title"].stringValue) + ","
                }
                _compentencyTitles = _compentencyTitles + "Knowledge" + "*"
                _compentencyDetails = _compentencyDetails + String(knowledgeStr.characters.dropLast()) + "*"
            }
            if (project["expertise"]!.arrayValue.count)>0 {
                var expertiseStr : String = ""
                let expertise: Array<JSON> = project["expertise"]!.arrayValue
                for experty in expertise {
                    expertiseStr = expertiseStr + (experty["et_name"].stringValue) + ","
                }
                _compentencyTitles = _compentencyTitles + "Skills and Expertise" + "*"
                _compentencyDetails = _compentencyDetails + String(expertiseStr.characters.dropLast()) + "*"
            }
            if (project["education"]!.arrayValue.count)>0 {
                var eduStr : String = ""
                let educations: Array<JSON> = project["education"]!.arrayValue
                for education in educations {
                    eduStr = eduStr + (education["education"].stringValue) + ","
                }
                _compentencyTitles = _compentencyTitles + "Degree" + "*"
                _compentencyDetails = _compentencyDetails + String(eduStr.characters.dropLast()) + "*"
            }
            if (project["studyfields"]!.arrayValue.count)>0 {
                var studyStr : String = ""
                let studyfields: Array<JSON> = project["studyfields"]!.arrayValue
                for studyfield in studyfields {
                    studyStr = studyStr + (studyfield["title"].stringValue) + ","
                }
                _compentencyTitles = _compentencyTitles + "Field of Study" + "*"
                _compentencyDetails = _compentencyDetails + String(studyStr.characters.dropLast()) + "*"
            }
            if (project["languages"]!.arrayValue.count)>0 {
                var langStr : String = ""
                let languages: Array<JSON> = project["languages"]!.arrayValue
                for language in languages {
                    langStr = langStr + (language["lang_name"].stringValue) + ","
                }
                _compentencyTitles = _compentencyTitles + "Languages" + "*"
                _compentencyDetails = _compentencyDetails + String(langStr.characters.dropLast()) + "*"
            }
            if (_compentencyTitles.isEmpty == false) {
                sections.append(Section(name: "Competency", items:[_compentencyTitles], details: [_compentencyDetails] , collapsed: true))
            }
            
            if (project["desired_skills"]!.stringValue.isEmpty==false) {
                _desiredSkills = project["desired_skills"]!.stringValue
                _desiredSkills = _desiredSkills.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                sections.append(Section(name: "Desired Skills", items:[_desiredSkills], details: [""] , collapsed: true))
            }
            if (project["project_what_we_offer"]!.stringValue.isEmpty==false) {
                _offersDetail = project["project_what_we_offer"]!.stringValue
                _offersDetail = _offersDetail.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                sections.append(Section(name: "What we offer?", items:[_offersDetail], details: [""] , collapsed: true))
            }
            self._jobDetailTableView.reloadData()
        }
    }
    
    func apiFailureResponseWithURL(errorDesc: String, urlString: String) {
        SVProgressHUD.dismiss()
        print("Failed \(errorDesc)")
        if urlString.containsString("project-interest") {
            // Interested or not-Interested
            Utility.displayMessage("API Failed!");
        }
    }
}
