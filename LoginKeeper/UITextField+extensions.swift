//
//  UITextField+extensions.swift
//  LoginKeeper
//
//  Created by Dusan Juranovic on 2/11/18.
//  Copyright © 2018 Dusan Juranovic. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func addLine() {
        let line = CGRect(x: 0, y: self.bounds.maxY, width: self.bounds.width, height: 0)
        let lineView = UIView(frame: line)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = .white
        self.addSubview(lineView)
        lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
