//
//  EntriesViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class EntriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

   
    
    //MARK: - Table View DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! EntriesCell
        
        return cell
    }
}
