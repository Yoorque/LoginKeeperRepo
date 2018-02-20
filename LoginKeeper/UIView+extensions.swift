//
//  UIView_extensions.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 2/11/18.
//  Copyright © 2018 Dusan Juranovic. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addGradient() {
        let gradient = CAGradientLayer()
        let c1 = UIColor(red: 54/255, green: 125/255, blue: 254/255, alpha: 1).cgColor
        let c2 = UIColor(red: 201/255, green: 70/255, blue: 254/255, alpha: 1).cgColor
        gradient.frame = self.bounds
        gradient.colors = [c1, c2]
        gradient.locations = [0.0, 1.0]
    
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIView {
    func addShadow() {
        self.contentMode = .scaleAspectFit
        self.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.5
        self.layer.cornerRadius = self.frame.size.width / 4
    }
}
