//
//  InfoTableViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/14/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController, BWWalkthroughViewControllerDelegate {
    @IBOutlet var feedbackCell: UITableViewCell!
    @IBOutlet var devWebsiteCell: UITableViewCell!
    @IBOutlet var moreAppsCell: UITableViewCell!
    @IBOutlet var iconsCell: UITableViewCell!
    @IBOutlet var versionLabel: UILabel!
    var authenticated: Bool?
    let accountsVC = AccountsViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticated = UserDefaults.standard.bool(forKey: "authenticated")
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return
        }
        let versionLocalized = NSLocalizedString("Version", comment: "")
        let buildLocalized = NSLocalizedString("build", comment: "")
        versionLabel.text = "\(versionLocalized) \(version) (\(buildLocalized) \(build))"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
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
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    // MARK: - Localization
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedCell = tableView.cellForRow(at: indexPath)
        switch clickedCell!.tag {
        case feedbackCell.tag:
            
            let email = "juranovicd@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                if authenticated == true {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    let alert = UIAlertController(title: errorLocalized, message: notAuthorisedLocalized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
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
            
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func leavingAppAlert(toURL url: URL, title: String) {
        let alert = UIAlertController(title: leavingLocalized, message: "\(leavingMessageLocalized) \(title). \(leavingMessageLocalized2)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: sureAnswerLocalized, style: .default, handler: { _ in
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: cancelAnswerLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func underContructionAlert() {
        
        let alert = UIAlertController(title: inProgressLocalized, message: workingLocalized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
