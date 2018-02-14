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
    
   
    @IBOutlet weak var logosCollectionView: UICollectionView!
    var account: Account!
    var viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGradient()
    }
    override func viewWillLayoutSubviews() {
        for v in view.layer.sublayers! {
            if v .isKind(of: CAGradientLayer.self) {
                v.frame = view.bounds
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logoImagesPNG.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "logoCell", for: indexPath) as! LogoCollectionViewCell
        cell.tag = indexPath.row
       
        if indexPath.row == 0 {
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 2
            cell.layer.cornerRadius = 15
            cell.currentLogoLabel.text = NSLocalizedString("Current/Suggested Logo", comment: "")
            cell.currentLogoLabel.backgroundColor = UIColor(red: 74/255, green: 122/255, blue: 246/255, alpha: 0.5)
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
                    self.displayAlert(title: errorLocalized, msg: unableToSaveMessageLocalized)
                }
            })
        })
    }
    func displayAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okLocalized, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
