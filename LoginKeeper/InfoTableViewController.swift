//
//  InfoTableViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/14/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {
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
        versionLabel.text = "Version \(version) (build \(build))"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedCell = tableView.cellForRow(at: indexPath)
        switch clickedCell!.tag {
        case feedbackCell.tag:
            
            let email = "juranovicd@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                if authenticated == true {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    let alert = UIAlertController(title: "Error", message: "You are not authorised to use this feature", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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
        let alert = UIAlertController(title: "Leaving LoginKeeper", message: "You will be redirected to \(title). Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I'm sure", style: .default, handler: { _ in
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func underContructionAlert() {
        let alert = UIAlertController(title: "In Progress...", message: "We're working on this one!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
