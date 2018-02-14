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
        view.addGradient()
        titleTextLabel.frame.size.height = 25
        titleTextLabel.textAlignment = .center
        titleTextLabel.textColor = UIColor.white
        titleTextLabel.font = UIFont(name: "Lato-Black", size: 17)
        titleTextLabel.text = aboutLocalized
        
        navigationItem.titleView = titleTextLabel
        aboutTextView.text = aboutTextLocalized
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        for v in view.layer.sublayers! {
            if v .isKind(of: CAGradientLayer.self) {
                v.frame = view.bounds
            }
        }
    }
}
