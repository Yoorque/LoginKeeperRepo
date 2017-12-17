//
//  LogosViewController.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 12/17/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit
import CoreData

class LogosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var account: Account!
    var viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logoImagesPNG.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "logoCell", for: indexPath) as! LogoCollectionViewCell
        cell.tag = indexPath.row
        if indexPath.row == 0 {
            cell.logoImageView.layer.borderColor = UIColor(displayP3Red: 60/255, green: 127/255, blue: 255/255, alpha: 1).cgColor
            cell.logoImageView.layer.borderWidth = 2
        }
        
        cell.logoImageView.image = UIImage(named: logoImagesPNG[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = collectionView.cellForItem(at: indexPath) as! LogoCollectionViewCell
        UIView.animate(withDuration: 0.2, animations: {
            selectedItem.logoImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: {_ in
            UIView.animate(withDuration: 0.2, animations: {
                selectedItem.logoImageView.transform = .identity
            }, completion: {_ in
                self.account.image = logoImagesPNG[selectedItem.tag]
                do {
                    try self.viewContext?.save()
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    
                }
            })
        })
    }
    
}
