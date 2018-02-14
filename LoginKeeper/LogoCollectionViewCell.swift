//
//  LogoCollectionViewCell.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 12/17/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class LogoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var currentLogoLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView! {
        didSet{
            logoImageView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            logoImageView.layer.cornerRadius = 15
            logoImageView.layer.shadowColor = UIColor.black.cgColor
            logoImageView.layer.shadowOpacity = 0.5
            logoImageView.layer.shadowOffset = CGSize(width: 0, height: 0)
            logoImageView.layer.shadowRadius = 2
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 0
        currentLogoLabel.text = ""
        currentLogoLabel.backgroundColor = nil
    }
    
}
