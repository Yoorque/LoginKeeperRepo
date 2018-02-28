//
//  InfoTableViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/14/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import MessageUI

class InfoTableViewController: UITableViewController, BWWalkthroughViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    //MARK: - Outlets
    @IBOutlet var feedbackCell: UITableViewCell!
    @IBOutlet var devWebsiteCell: UITableViewCell!
    @IBOutlet var moreAppsCell: UITableViewCell!
    @IBOutlet var iconsCell: UITableViewCell!
    @IBOutlet var walkthroughDevCell: UITableViewCell!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet weak var removeAds: UIButton!

    //MARK: - Properties
    let walkthrough = BWWalkthroughViewController()
    var authenticated: Bool?
    let accountsVC = AccountsViewController()
    var version: String!
    var build: String!
    var bcgView = UIView()
    
    //MARK: - App life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .scrollableAxes
        }
        bcgView.frame = self.view.frame
        bcgView.addGradient()
        tableView.backgroundView = bcgView
        
        authenticated = UserDefaults.standard.bool(forKey: "authenticated")
        version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        
        versionLabel.text = "\(versionLocalized) \(version!) (\(buildLocalized) \(build!))"
        removeAds.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = false
        if UserDefaults.standard.bool(forKey: "premiumPurchased") {
            removeAds.setTitle(premiumVersionLocalized, for: .normal)
            removeAds.backgroundColor = UIColor(red: 44/255, green: 152/255, blue: 41/255, alpha: 1)
        } else {
            removeAds.setTitle(removeAdsLocalized, for: .normal)
            removeAds.backgroundColor = UIColor(red: 216/255, green: 67/255, blue: 35/255, alpha: 1)
        }
    }
    
    override func viewWillLayoutSubviews() {
        bcgView.layer.sublayers?.removeAll()
        bcgView.addGradient()
        bcgView.frame = self.view.frame
    }
    
    //MARK: - Mail Functionality
    func sendEmail() {
        let compose = MFMailComposeViewController()
        compose.mailComposeDelegate = self
        compose.setToRecipients(["simpleloginkeeper@gmail.com"])
        compose.setSubject("\(subjectLocalized) \(UIDevice.current.name.replacingOccurrences(of: "'s iPhone", with: ""))")
        compose.setMessageBody("\(deviceLocalized) \(UIDevice.current.model), \(UIDevice.current.systemName) \(UIDevice.current.systemVersion) \n\(appVersionLocalized) \(version!) (\(buildLocalized) \(build!)) \n\(enterFeedbackLocalized)", isHTML: false)
        
        self.present(compose, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    //MARK: - RemoveAds Button
    @IBAction func removeAdsButton(_ sender: UIButton) {
        if authenticated == true {
            performSegue(withIdentifier: "removeAdsSegue", sender: self)
        } else {
            notAuthorizedAlert()
        }
    }
    
    //MARK: - Tutorial
    @IBAction func tutorialActionButton(_ sender: Any) {
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "Screen0") as! BWWalkthroughViewController
        let pageOne = stb.instantiateViewController(withIdentifier: "Screen1")
        let pageTwo = stb.instantiateViewController(withIdentifier: "Screen2")
        let pageThree = stb.instantiateViewController(withIdentifier: "Screen3")
        let pageFour = stb.instantiateViewController(withIdentifier: "Screen4")
        let pageFive = stb.instantiateViewController(withIdentifier: "Screen5")
        let pageSix = stb.instantiateViewController(withIdentifier: "Screen6")
        
        walkthrough.delegate = self
        walkthrough.add(viewController: pageOne)
        walkthrough.add(viewController: pageTwo)
        walkthrough.add(viewController: pageThree)
        walkthrough.add(viewController: pageFour)
        walkthrough.add(viewController: pageFive)
        walkthrough.add(viewController: pageSix)
        
        self.present(walkthrough, animated: true, completion: nil)
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedCell = tableView.cellForRow(at: indexPath)
        if indexPath.row != 0 {
            for logoView in clickedCell!.contentView.subviews {
                if logoView .isKind(of: UIImageView.self) {
                    UIView.animate(withDuration: 0.2, animations: {
                        logoView.transform = CGAffineTransform(scaleX: 1, y: 0.3)
                    }, completion: {_ in
                        UIView.animate(withDuration: 0.2, animations: {
                            logoView.transform = .identity
                        })
                    })
                }
            }
        }
        switch clickedCell!.tag {
        case feedbackCell.tag:
            if authenticated == true {
//                let alert = UIAlertController(title: "LoginKeeper", message: "Please choose an option for leaving feedback.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "App Store Review", style: .default, handler: {_ in
                    let appID = "1317604418"
                    let urlStr = "https://itunes.apple.com/us/app/appName/id\(appID)?mt=8&action=write-review"
                    
                    if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                        self.leavingAppAlert(toURL: url, title: "App Store")
                    }
//                }))
//                alert.addAction(UIAlertAction(title: "Email Developer", style: .default, handler: {_ in
//                    if MFMailComposeViewController.canSendMail() {
//                        self.sendEmail()
//                    } else {
//                        self.noMailFuncAlert()
//                    }
//                }))
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                present(alert, animated: true, completion: nil)
//            } else {
//                notAuthorizedAlert()
                }
        case devWebsiteCell.tag:
            
            if let url = URL(string: "https://linkedin.com/in/dusan-juranovic") {
                leavingAppAlert(toURL: url, title: "LinkedIn")
            }
            
        case moreAppsCell.tag:
            
            underContructionAlert()
            
        case iconsCell.tag:
            
            if let url = URL(string: "https://icons8.com") {
                leavingAppAlert(toURL: url, title: "icons8.com")
            }
            
        case walkthroughDevCell.tag:
            if let url = URL(string: "https://github.com/ariok/BWWalkthrough") {
                leavingAppAlert(toURL: url, title: "GitHub")
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Alerts
    func notAuthorizedAlert() {
        let alert = UIAlertController(title: errorLocalized, message: notAuthorisedLocalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func noMailFuncAlert() {
        let alert = UIAlertController(title: errorLocalized, message: noMailFuncLocalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func leavingAppAlert(toURL url: URL, title: String) {
        let alert = UIAlertController(title: leavingLocalized, message: "\(leavingMessageLocalized) \(title). \(leavingMessageLocalized2)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: sureAnswerLocalized, style: .default, handler: { _ in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: cancelAnswerLocalized, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func underContructionAlert() {
        
        let alert = UIAlertController(title: inProgressLocalized, message: workingLocalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
