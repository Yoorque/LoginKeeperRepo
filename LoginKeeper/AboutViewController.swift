//
//  AboutViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 11/28/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    var titleTextLabel = UILabel()
    
    @IBOutlet weak var aboutTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextLabel.frame.size.height = 25
        titleTextLabel.textAlignment = .center
        titleTextLabel.textColor = UIColor(red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        titleTextLabel.font = UIFont(name: "Lato-Black", size: 17)
        titleTextLabel.text = aboutLocalized
        
        navigationItem.titleView = titleTextLabel
        aboutTextView.text = aboutTextLocalized
        // Do any additional setup after loading the view.
    }
}
