//
//  AccountsCell.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 7/6/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

protocol AccountsDisplayAlertDelegate {
    func coreDataAlert(message: String)
}
protocol ShowLogoDelegate {
    func showLogosForRow(at: Int)
}

class AccountsCell: UITableViewCell {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate: AccountsDisplayAlertDelegate?
    var showLogoDelegate: ShowLogoDelegate?
    
    @IBOutlet var favoriteImageView: UIImageView! {
        didSet {
            favoriteImageView.image = UIImage(named: "emptyStar")
            let gesture = UITapGestureRecognizer(target: self, action: #selector(starGesture))
            favoriteImageView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet var accountImageView: UIImageView! {
        didSet {
            accountImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeLogo))
            accountImageView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet var accountNameLabel: UILabel!    
    @IBOutlet var entriesCountForAccountLabel: UILabel!
    var accountForCell: Account!
    
    @objc func starGesture(sender: UITapGestureRecognizer) {
        if let view = sender.view as? UIImageView{
            
            fetch(account: accountNameLabel.text!)
            
            if (accountForCell.entries?.allObjects.first as! Entry).favorited == true {
                view.image = UIImage(named: "emptyStar")
                (accountForCell.entries?.allObjects.first as! Entry).favorited = false
            } else {
                view.image = UIImage(named: "star")
                (accountForCell.entries?.allObjects.first as! Entry).favorited = true
            }
            
            
            do {
                try context.save()
            } catch {
                delegate?.coreDataAlert(message: "Can't save to favorites.")
            }
        }
    }
    
    @objc func changeLogo(sender: UITapGestureRecognizer) {
        if let view = sender.view as? UIImageView {
            UIView.animate(withDuration: 0.2, animations: {
                view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: {_ in
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = .identity
                }, completion: {_ in
                    self.showLogoDelegate?.showLogosForRow(at: view.tag)
                })
            })
        }
    }
    
    func fetch(account: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let predicate = NSPredicate(format: "name == %@", account)
        fetchRequest.predicate = predicate
        
        do {
            accountForCell = try context.fetch(fetchRequest).first as! Account
        } catch {
            print("Unable to fetch: \(error)")
            delegate?.coreDataAlert(message: unableToFetchMessageLocalized)
        }
    }
    
}
