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
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextLabel.frame.size.height = 25
        titleTextLabel.textAlignment = .center
        titleTextLabel.textColor = UIColor(red: 56/255, green: 124/255, blue: 254/255, alpha: 1)
        titleTextLabel.font = UIFont(name: "HiraginoSans-W6", size: 15)
        titleTextLabel.text = "About LoginKeeper"
        navigationItem.titleView = titleTextLabel
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
