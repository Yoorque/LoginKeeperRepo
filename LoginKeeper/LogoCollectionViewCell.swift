//
//  LogoCollectionViewCell.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 12/17/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class LogoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var logoImageView: UIImageView! {
        didSet{
            logoImageView.layer.masksToBounds = true
            logoImageView.layer.shadowColor = UIColor.black.cgColor
            logoImageView.layer.shadowOpacity = 0.5
            logoImageView.layer.shadowOffset = CGSize(width: 2, height: 2)
            logoImageView.layer.shadowRadius = 2
        }
    }
    
}
